const express = require('express');
const { ObjectId } = require('mongodb');
const { getDb } = require('../db');
const { HttpError, dec, num, oid, fecha, serializar, filtroFecha, ah } = require('../utils');
const { enTransaccion, cuentaDelUsuario, montoBase, moverSaldo, tasaCambio } = require('../movimientos');

const r = express.Router();
const col = () => getDb().collection('transferencias');

// GET /api/transferencias  ?cuenta_origen_id=  ?cuenta_id= (origen o destino)  ?periodo= | ?desde=&hasta=
r.get('/', ah(async (req, res) => {
  const q = req.query;
  const filtro = { uid: req.uid, ...filtroFecha(q) };
  if (q.cuenta_origen_id) filtro.cuenta_origen_id = oid(q.cuenta_origen_id, 'cuenta_origen_id');
  if (q.cuenta_destino_id) filtro.cuenta_destino_id = oid(q.cuenta_destino_id, 'cuenta_destino_id');
  if (q.cuenta_id) {
    const id = oid(q.cuenta_id, 'cuenta_id');
    filtro.$or = [{ cuenta_origen_id: id }, { cuenta_destino_id: id }];
  }
  res.json(serializar(await col().find(filtro).sort({ fecha: -1 }).toArray()));
}));

r.get('/:id', ah(async (req, res) => {
  const t = await col().findOne({ _id: oid(req.params.id), uid: req.uid });
  if (!t) throw new HttpError(404, 'Transferencia no encontrada');
  res.json(serializar(t));
}));

// POST /api/transferencias
//   { cuenta_origen_id, cuenta_destino_id, monto (o monto_origen), descripcion, fecha,
//     monto_destino? | tasa? }  -> si las monedas son distintas y no se envía ni
//   monto_destino ni tasa, se usa la última tasa de tasas_cambio.
// Crea la transferencia + 2 transacciones enlazadas (salida/entrada) en una sola sesión.
r.post('/', ah(async (req, res) => {
  const b = req.body;
  const montoOrigen = Number(b.monto_origen ?? b.monto);
  if (!(montoOrigen > 0)) throw new HttpError(400, 'monto debe ser mayor que 0');
  if (b.cuenta_origen_id === b.cuenta_destino_id) throw new HttpError(400, 'La cuenta de origen y destino deben ser distintas');

  const doc = await enTransaccion(async (session) => {
    const origen = await cuentaDelUsuario(req.uid, b.cuenta_origen_id, session);
    const destino = await cuentaDelUsuario(req.uid, b.cuenta_destino_id, session);

    let tasa = null;
    let montoDestino = montoOrigen;
    if (b.monto_destino !== undefined) {
      montoDestino = Number(b.monto_destino);
      tasa = montoDestino / montoOrigen;
    } else if (b.tasa !== undefined) {
      tasa = Number(b.tasa);
      montoDestino = montoOrigen * tasa;
    } else if (origen.moneda !== destino.moneda) {
      tasa = await tasaCambio(origen.moneda, destino.moneda, session);
      if (tasa === null) throw new HttpError(422, `No hay tasa ${origen.moneda}->${destino.moneda}; envía "tasa" o "monto_destino"`);
      montoDestino = montoOrigen * tasa;
    }

    const ahora = new Date();
    const f = fecha(b.fecha);
    const descripcion = String(b.descripcion || '');
    const transferenciaId = new ObjectId();
    const salidaId = new ObjectId();
    const entradaId = new ObjectId();
    const base = (cuenta, monto) => montoBase(req.uid, monto, cuenta.moneda, session);
    const comun = { uid: req.uid, tipo: 'transferencia', fecha: f, descripcion, categoria: null, transferencia_id: transferenciaId, pago_automatico_id: null, id_local: null, sincronizada: true, creada_en: ahora, actualizada_en: ahora };

    await getDb().collection('transacciones').insertMany(
      [
        { _id: salidaId, cuenta_id: origen._id, monto: dec(montoOrigen), moneda: origen.moneda, ...(await base(origen, montoOrigen)), ...comun },
        { _id: entradaId, cuenta_id: destino._id, monto: dec(montoDestino), moneda: destino.moneda, ...(await base(destino, montoDestino)), ...comun },
      ],
      { session }
    );

    const transferencia = {
      _id: transferenciaId,
      uid: req.uid,
      cuenta_origen_id: origen._id,
      cuenta_destino_id: destino._id,
      monto_origen: dec(montoOrigen),
      moneda_origen: origen.moneda,
      monto_destino: dec(montoDestino),
      moneda_destino: destino.moneda,
      tasa_aplicada: tasa === null ? null : dec(tasa),
      descripcion,
      fecha: f,
      transaccion_salida_id: salidaId,
      transaccion_entrada_id: entradaId,
    };
    await col().insertOne(transferencia, { session });
    await moverSaldo(origen._id, -montoOrigen, session);
    await moverSaldo(destino._id, montoDestino, session);
    return transferencia;
  });
  res.status(201).json(serializar(doc));
}));

// DELETE /api/transferencias/:id -> revierte ambos saldos y borra las 2 transacciones
r.delete('/:id', ah(async (req, res) => {
  await enTransaccion(async (session) => {
    const t = await col().findOne({ _id: oid(req.params.id), uid: req.uid }, { session });
    if (!t) throw new HttpError(404, 'Transferencia no encontrada');
    await moverSaldo(t.cuenta_origen_id, num(t.monto_origen), session);
    await moverSaldo(t.cuenta_destino_id, -num(t.monto_destino), session);
    await getDb().collection('transacciones').deleteMany({ _id: { $in: [t.transaccion_salida_id, t.transaccion_entrada_id] } }, { session });
    await col().deleteOne({ _id: t._id }, { session });
  });
  res.json({ ok: true });
}));

module.exports = r;

const express = require('express');
const { getDb } = require('../db');
const { HttpError, dec, num, oid, moneda, serializar, ah } = require('../utils');
const { enTransaccion, cuentaDelUsuario, moverSaldo, preferencias } = require('../movimientos');

const r = express.Router();
const cuentas = () => getDb().collection('cuentas');
const TIPOS = ['tarjeta', 'banco', 'efectivo', 'billetera'];

function tipoCuenta(valor) {
  const t = String(valor || 'banco').toLowerCase();
  if (!TIPOS.includes(t)) throw new HttpError(400, `tipo_cuenta debe ser uno de: ${TIPOS.join(', ')}`);
  return t;
}

// GET /api/cuentas -> cuentas del usuario
r.get('/', ah(async (req, res) => {
  const lista = await cuentas().find({ uid: req.uid }).sort({ creada_en: 1 }).toArray();
  res.json(serializar(lista));
}));

// GET /api/cuentas/:id
r.get('/:id', ah(async (req, res) => {
  res.json(serializar(await cuentaDelUsuario(req.uid, req.params.id)));
}));

// GET /api/cuentas/:id/saldo -> { saldo }
r.get('/:id/saldo', ah(async (req, res) => {
  const c = await cuentaDelUsuario(req.uid, req.params.id);
  res.json({ saldo: num(c.saldo), moneda: c.moneda });
}));

// POST /api/cuentas  { nombre_cuenta, saldo_inicial | saldo, moneda, icono_cuenta, tipo_cuenta }
r.post('/', ah(async (req, res) => {
  const b = req.body;
  if (!b.nombre_cuenta) throw new HttpError(400, 'nombre_cuenta es requerido');
  const { moneda_principal } = await preferencias(req.uid);
  const inicial = dec(b.saldo_inicial ?? b.saldo ?? 0);
  const ahora = new Date();
  const doc = {
    uid: req.uid,
    nombre_cuenta: String(b.nombre_cuenta),
    tipo_cuenta: tipoCuenta(b.tipo_cuenta),
    moneda: moneda(b.moneda, moneda_principal),
    icono_cuenta: String(b.icono_cuenta || ''),
    saldo_inicial: inicial,
    saldo: inicial,
    creada_en: ahora,
    actualizada_en: ahora,
  };
  const { insertedId } = await cuentas().insertOne(doc);
  res.status(201).json(serializar({ _id: insertedId, ...doc }));
}));

// PUT /api/cuentas/:id  { nombre_cuenta?, moneda?, icono_cuenta?, tipo_cuenta?, saldo? }
// Si llega "saldo", se ajusta saldo_inicial por la diferencia para que
// saldo = saldo_inicial + movimientos siga cuadrando.
r.put('/:id', ah(async (req, res) => {
  const b = req.body;
  const actual = await cuentaDelUsuario(req.uid, req.params.id);
  const set = { actualizada_en: new Date() };
  if (b.nombre_cuenta !== undefined) set.nombre_cuenta = String(b.nombre_cuenta);
  if (b.moneda !== undefined) set.moneda = moneda(b.moneda);
  if (b.icono_cuenta !== undefined) set.icono_cuenta = String(b.icono_cuenta);
  if (b.tipo_cuenta !== undefined) set.tipo_cuenta = tipoCuenta(b.tipo_cuenta);
  if (b.saldo !== undefined) {
    const diferencia = Number(b.saldo) - num(actual.saldo);
    set.saldo = dec(b.saldo);
    set.saldo_inicial = dec(num(actual.saldo_inicial) + diferencia);
  }
  await cuentas().updateOne({ _id: actual._id }, { $set: set });
  res.json(serializar({ ...actual, ...set }));
}));

// DELETE /api/cuentas/:id -> borra la cuenta, sus movimientos y sus transferencias
// (devolviendo el saldo a la otra cuenta de cada transferencia).
r.delete('/:id', ah(async (req, res) => {
  const db = getDb();
  const resumen = await enTransaccion(async (session) => {
    const cuenta = await cuentaDelUsuario(req.uid, req.params.id, session);
    const transfers = await db
      .collection('transferencias')
      .find({ uid: req.uid, $or: [{ cuenta_origen_id: cuenta._id }, { cuenta_destino_id: cuenta._id }] }, { session })
      .toArray();

    for (const t of transfers) {
      if (t.cuenta_origen_id.equals(cuenta._id) && !t.cuenta_destino_id.equals(cuenta._id)) {
        await moverSaldo(t.cuenta_destino_id, -num(t.monto_destino), session);
      } else if (t.cuenta_destino_id.equals(cuenta._id) && !t.cuenta_origen_id.equals(cuenta._id)) {
        await moverSaldo(t.cuenta_origen_id, num(t.monto_origen), session);
      }
      await db.collection('transacciones').deleteMany({ _id: { $in: [t.transaccion_salida_id, t.transaccion_entrada_id] } }, { session });
    }
    await db.collection('transferencias').deleteMany({ _id: { $in: transfers.map((t) => t._id) } }, { session });
    const { deletedCount } = await db.collection('transacciones').deleteMany({ uid: req.uid, cuenta_id: cuenta._id }, { session });
    await cuentas().deleteOne({ _id: cuenta._id }, { session });
    return { transacciones_borradas: deletedCount, transferencias_borradas: transfers.length };
  });
  res.json({ ok: true, ...resumen });
}));

// POST /api/cuentas/convertir-divisa  { moneda, tasa }
// Reemplaza CambiosDivisaController: pasa todas las cuentas del usuario (y sus
// movimientos) a otra moneda multiplicando por la tasa.
r.post('/convertir-divisa', ah(async (req, res) => {
  const nueva = moneda(req.body.moneda);
  const tasa = Number(req.body.tasa);
  if (!Number.isFinite(tasa) || tasa <= 0) throw new HttpError(400, 'tasa debe ser un número mayor que 0');
  const db = getDb();
  const t = dec(tasa);
  const resultado = await enTransaccion(async (session) => {
    const ids = (await cuentas().find({ uid: req.uid }, { projection: { _id: 1 }, session }).toArray()).map((c) => c._id);
    const ahora = new Date();
    const c = await cuentas().updateMany(
      { _id: { $in: ids } },
      [{ $set: { moneda: nueva, saldo: { $multiply: ['$saldo', t] }, saldo_inicial: { $multiply: ['$saldo_inicial', t] }, actualizada_en: ahora } }],
      { session }
    );
    const m = await db.collection('transacciones').updateMany(
      { uid: req.uid, cuenta_id: { $in: ids } },
      [{ $set: { moneda: nueva, monto: { $multiply: ['$monto', t] }, actualizada_en: ahora } }],
      { session }
    );
    return { cuentas: c.modifiedCount, transacciones: m.modifiedCount };
  });
  res.json({ ok: true, ...resultado });
}));

module.exports = r;

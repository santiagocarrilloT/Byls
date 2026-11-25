const express = require('express');
const { getDb } = require('../db');
const { HttpError, dec, num, oid, oidONull, fecha, tipoMovimiento, serializar, filtroFecha, ah } = require('../utils');
const { enTransaccion, cuentaDelUsuario, resolverCategoria, montoBase, signo, moverSaldo } = require('../movimientos');
const { evaluarPorFecha } = require('./presupuestos');

// Tras cada gasto se re-evalúan los presupuestos de esa fecha (RF-21). No bloquea la respuesta.
function reevaluar(uid, ...fechas) {
  for (const f of fechas) if (f) evaluarPorFecha(uid, f).catch((e) => console.error('Error evaluando presupuestos:', e.message));
}

const r = express.Router();
const col = () => getDb().collection('transacciones');

// GET /api/transacciones
//   ?cuenta_id=  ?tipo=ingreso|gasto  ?categoria_id=
//   ?periodo=Día|Semana|Mes|Año|Todos (&mes=1-12 &anio=2026)  o  ?desde=&hasta=
//   ?incluir_transferencias=true  (por defecto se omiten, como en la app actual)
r.get('/', ah(async (req, res) => {
  const q = req.query;
  const filtro = { uid: req.uid, ...filtroFecha(q) };
  if (q.cuenta_id) filtro.cuenta_id = oid(q.cuenta_id, 'cuenta_id');
  if (q.categoria_id) filtro['categoria.id'] = oid(q.categoria_id, 'categoria_id');
  if (q.tipo) filtro.tipo = String(q.tipo).toLowerCase();
  else if (q.incluir_transferencias !== 'true') filtro.tipo = { $in: ['ingreso', 'gasto'] };
  const lista = await col().find(filtro).sort({ fecha: -1 }).limit(Math.min(Number(q.limite) || 1000, 5000)).toArray();
  res.json(serializar(lista));
}));

r.get('/:id', ah(async (req, res) => {
  const t = await col().findOne({ _id: oid(req.params.id), uid: req.uid });
  if (!t) throw new HttpError(404, 'Transacción no encontrada');
  res.json(serializar(t));
}));

// POST /api/transacciones
//   { cuenta_id, tipo, monto, fecha, descripcion, categoria_id | nombre_categoria, id_local?, pago_automatico_id? }
// Inserta el movimiento y actualiza el saldo de la cuenta en la misma sesión (RF-07).
r.post('/', ah(async (req, res) => {
  const b = req.body;
  const tipo = tipoMovimiento(b.tipo);
  const monto = Number(b.monto);
  if (!(monto > 0)) throw new HttpError(400, 'monto debe ser mayor que 0');

  const resultado = await enTransaccion(async (session) => {
    // Idempotencia para la sincronización offline (RF-30)
    if (b.id_local) {
      const existente = await col().findOne({ uid: req.uid, id_local: String(b.id_local) }, { session });
      if (existente) return { doc: existente, repetida: true };
    }
    const cuenta = await cuentaDelUsuario(req.uid, b.cuenta_id, session);
    const base = await montoBase(req.uid, monto, cuenta.moneda, session);
    const ahora = new Date();
    const doc = {
      uid: req.uid,
      cuenta_id: cuenta._id,
      tipo,
      monto: dec(monto),
      moneda: cuenta.moneda,
      ...base,
      fecha: fecha(b.fecha),
      descripcion: String(b.descripcion || ''),
      categoria: await resolverCategoria(req.uid, { categoria_id: b.categoria_id, nombre_categoria: b.nombre_categoria, tipo }, session),
      transferencia_id: null,
      pago_automatico_id: oidONull(b.pago_automatico_id, 'pago_automatico_id'),
      id_local: b.id_local ? String(b.id_local) : null,
      sincronizada: true,
      creada_en: ahora,
      actualizada_en: ahora,
    };
    const { insertedId } = await col().insertOne(doc, { session });
    await moverSaldo(cuenta._id, signo(tipo) * monto, session);
    return { doc: { _id: insertedId, ...doc }, repetida: false };
  });
  if (!resultado.repetida && tipo === 'gasto') reevaluar(req.uid, resultado.doc.fecha);
  res.status(resultado.repetida ? 200 : 201).json(serializar(resultado.doc));
}));

// PUT /api/transacciones/:id  (cualquier campo del POST)
// Revierte el efecto anterior en el saldo y aplica el nuevo; soporta cambio de cuenta, tipo y monto.
r.put('/:id', ah(async (req, res) => {
  const b = req.body;
  const doc = await enTransaccion(async (session) => {
    const anterior = await col().findOne({ _id: oid(req.params.id), uid: req.uid }, { session });
    if (!anterior) throw new HttpError(404, 'Transacción no encontrada');
    if (anterior.tipo === 'transferencia') throw new HttpError(409, 'Esta transacción es parte de una transferencia: edítala o bórrala desde /api/transferencias');

    const tipo = b.tipo !== undefined ? tipoMovimiento(b.tipo) : anterior.tipo;
    const monto = b.monto !== undefined ? Number(b.monto) : num(anterior.monto);
    if (!(monto > 0)) throw new HttpError(400, 'monto debe ser mayor que 0');
    const cuenta = b.cuenta_id !== undefined ? await cuentaDelUsuario(req.uid, b.cuenta_id, session) : await cuentaDelUsuario(req.uid, anterior.cuenta_id.toHexString(), session);

    // 1) deshacer el movimiento anterior  2) aplicar el nuevo
    await moverSaldo(anterior.cuenta_id, -signo(anterior.tipo) * num(anterior.monto), session);
    await moverSaldo(cuenta._id, signo(tipo) * monto, session);

    const set = {
      cuenta_id: cuenta._id,
      tipo,
      monto: dec(monto),
      moneda: cuenta.moneda,
      ...(await montoBase(req.uid, monto, cuenta.moneda, session)),
      fecha: b.fecha !== undefined ? fecha(b.fecha) : anterior.fecha,
      descripcion: b.descripcion !== undefined ? String(b.descripcion) : anterior.descripcion,
      categoria:
        b.categoria_id !== undefined || b.nombre_categoria !== undefined
          ? await resolverCategoria(req.uid, { categoria_id: b.categoria_id, nombre_categoria: b.nombre_categoria, tipo }, session)
          : anterior.categoria,
      sincronizada: true,
      actualizada_en: new Date(),
    };
    await col().updateOne({ _id: anterior._id }, { $set: set }, { session });
    return { ...anterior, ...set, fecha_anterior: anterior.fecha };
  });
  reevaluar(req.uid, doc.fecha, doc.fecha_anterior);
  delete doc.fecha_anterior;
  res.json(serializar(doc));
}));

// DELETE /api/transacciones/:id  -> borra y devuelve el saldo
r.delete('/:id', ah(async (req, res) => {
  const borrada = await enTransaccion(async (session) => {
    const t = await col().findOne({ _id: oid(req.params.id), uid: req.uid }, { session });
    if (!t) throw new HttpError(404, 'Transacción no encontrada');
    if (t.tipo === 'transferencia') throw new HttpError(409, 'Esta transacción es parte de una transferencia: bórrala desde /api/transferencias');
    await moverSaldo(t.cuenta_id, -signo(t.tipo) * num(t.monto), session);
    await col().deleteOne({ _id: t._id }, { session });
    return t;
  });
  if (borrada.tipo === 'gasto') reevaluar(req.uid, borrada.fecha);
  res.json({ ok: true });
}));

// DELETE /api/transacciones?cuenta_id=  -> borra todos los movimientos (ingreso/gasto) de una cuenta
r.delete('/', ah(async (req, res) => {
  if (!req.query.cuenta_id) throw new HttpError(400, 'cuenta_id es requerido');
  const borradas = await enTransaccion(async (session) => {
    const cuenta = await cuentaDelUsuario(req.uid, req.query.cuenta_id, session);
    const lista = await col().find({ uid: req.uid, cuenta_id: cuenta._id, tipo: { $in: ['ingreso', 'gasto'] } }, { session }).toArray();
    const delta = lista.reduce((acc, t) => acc - signo(t.tipo) * num(t.monto), 0);
    await moverSaldo(cuenta._id, delta, session);
    const { deletedCount } = await col().deleteMany({ _id: { $in: lista.map((t) => t._id) } }, { session });
    return deletedCount;
  });
  res.json({ ok: true, borradas });
}));

module.exports = r;

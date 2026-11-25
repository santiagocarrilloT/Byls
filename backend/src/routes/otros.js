// Notificaciones, preferencias de usuario y tasas de cambio.
const express = require('express');
const { Int32 } = require('mongodb');
const { getDb } = require('../db');
const { HttpError, dec, oid, fecha, moneda, serializar, ah } = require('../utils');
const { preferencias } = require('../movimientos');

// ---------------- notificaciones ----------------
const notificaciones = express.Router();
const notis = () => getDb().collection('notificaciones');

// GET /api/notificaciones ?leida=false
notificaciones.get('/', ah(async (req, res) => {
  const filtro = { uid: req.uid };
  if (req.query.leida !== undefined) filtro.leida = req.query.leida === 'true';
  res.json(serializar(await notis().find(filtro).sort({ leida: 1, creada_en: -1 }).limit(200).toArray()));
}));

// PATCH /api/notificaciones/:id/leida  { leida: true }
notificaciones.patch('/:id/leida', ah(async (req, res) => {
  const leida = req.body.leida !== false;
  const { matchedCount } = await notis().updateOne({ _id: oid(req.params.id), uid: req.uid }, { $set: { leida } });
  if (!matchedCount) throw new HttpError(404, 'Notificación no encontrada');
  res.json({ ok: true, leida });
}));

// POST /api/notificaciones/leer-todas
notificaciones.post('/leer-todas', ah(async (req, res) => {
  const { modifiedCount } = await notis().updateMany({ uid: req.uid, leida: false }, { $set: { leida: true } });
  res.json({ ok: true, marcadas: modifiedCount });
}));

notificaciones.delete('/:id', ah(async (req, res) => {
  const { deletedCount } = await notis().deleteOne({ _id: oid(req.params.id), uid: req.uid });
  if (!deletedCount) throw new HttpError(404, 'Notificación no encontrada');
  res.json({ ok: true });
}));

// ---------------- preferencias_usuario (1 a 1 con el usuario) ----------------
const prefs = express.Router();

// GET /api/preferencias -> si no existen, devuelve los valores por defecto
prefs.get('/', ah(async (req, res) => {
  res.json({ uid: req.uid, ...(await preferencias(req.uid)) });
}));

// PUT /api/preferencias { moneda_principal?, umbral_gasto_hormiga?, frecuencia_hormiga_minima?, porcentaje_alerta_presupuesto? }
prefs.put('/', ah(async (req, res) => {
  const b = req.body;
  const actual = await preferencias(req.uid);
  const entero = (v, campo, min, max) => {
    const n = Number(v);
    if (!Number.isInteger(n) || n < min || n > max) throw new HttpError(400, `${campo} debe ser un entero entre ${min} y ${max}`);
    return new Int32(n);
  };
  const doc = {
    uid: req.uid,
    moneda_principal: moneda(b.moneda_principal ?? actual.moneda_principal),
    umbral_gasto_hormiga: dec(b.umbral_gasto_hormiga ?? actual.umbral_gasto_hormiga),
    frecuencia_hormiga_minima: entero(b.frecuencia_hormiga_minima ?? actual.frecuencia_hormiga_minima, 'frecuencia_hormiga_minima', 1, 1000),
    porcentaje_alerta_presupuesto: entero(b.porcentaje_alerta_presupuesto ?? actual.porcentaje_alerta_presupuesto, 'porcentaje_alerta_presupuesto', 1, 100),
    actualizado_en: new Date(),
  };
  await getDb().collection('preferencias_usuario').updateOne({ uid: req.uid }, { $set: doc }, { upsert: true });
  res.json(serializar(doc));
}));

// ---------------- tasas_cambio (pública para todos los usuarios) ----------------
const tasas = express.Router();
const tc = () => getDb().collection('tasas_cambio');

// GET /api/tasas-cambio ?moneda_origen=USD&moneda_destino=COP -> la más reciente; sin filtros, las últimas 100
tasas.get('/', ah(async (req, res) => {
  const { moneda_origen: o, moneda_destino: d } = req.query;
  if (o && d) {
    const t = await tc().findOne({ moneda_origen: moneda(o), moneda_destino: moneda(d) }, { sort: { fecha: -1 } });
    if (!t) throw new HttpError(404, `No hay tasa ${o}->${d}`);
    return res.json(serializar(t));
  }
  res.json(serializar(await tc().find({}).sort({ fecha: -1 }).limit(100).toArray()));
}));

// POST /api/tasas-cambio { moneda_origen, moneda_destino, tasa, fecha?, fuente? }
// Upsert por (origen, destino, fecha): el índice único evita duplicados.
tasas.post('/', ah(async (req, res) => {
  const b = req.body;
  const f = fecha(b.fecha);
  f.setUTCHours(0, 0, 0, 0); // una tasa por día
  const doc = { moneda_origen: moneda(b.moneda_origen), moneda_destino: moneda(b.moneda_destino), tasa: dec(b.tasa), fecha: f, fuente: String(b.fuente || 'manual') };
  await tc().updateOne({ moneda_origen: doc.moneda_origen, moneda_destino: doc.moneda_destino, fecha: f }, { $set: doc }, { upsert: true });
  res.status(201).json(serializar(doc));
}));

module.exports = { notificaciones, prefs, tasas };

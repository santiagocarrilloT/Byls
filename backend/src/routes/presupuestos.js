const express = require('express');
const { getDb } = require('../db');
const { HttpError, dec, num, oid, fecha, moneda, serializar, ah } = require('../utils');
const { preferencias } = require('../movimientos');

const r = express.Router();
const col = () => getDb().collection('presupuestos');
const PERIODOS = ['semanal', 'mensual', 'personalizado'];

/** Suma de gastos (monto_base) por categoría en un rango. */
async function gastadoPorCategoria(uid, desde, hasta) {
  const filas = await getDb()
    .collection('transacciones')
    .aggregate([
      { $match: { uid, tipo: 'gasto', fecha: { $gte: desde, $lte: hasta } } },
      { $group: { _id: '$categoria.id', total: { $sum: '$monto_base' } } },
    ])
    .toArray();
  const mapa = new Map();
  let total = 0;
  for (const f of filas) {
    const v = num(f.total);
    total += v;
    if (f._id) mapa.set(f._id.toHexString(), v);
  }
  return { mapa, total };
}

function estado(gastado, limite, pctAlerta) {
  if (gastado > limite) return 'excedido';
  if (limite > 0 && gastado >= (limite * pctAlerta) / 100) return 'al_limite';
  return 'cumplido';
}

/**
 * Recalcula gastado/estado por categoría, disponible_para_gastar, la comparación con
 * el periodo anterior (RF-18 a RF-20) y genera notificaciones (RF-21).
 */
async function evaluar(presupuesto) {
  const db = getDb();
  const { uid, periodo_inicio: ini, periodo_fin: fin } = presupuesto;
  const { porcentaje_alerta_presupuesto: pct } = await preferencias(uid);

  const actual = await gastadoPorCategoria(uid, ini, fin);
  const duracion = fin.getTime() - ini.getTime();
  const anterior = await gastadoPorCategoria(uid, new Date(ini.getTime() - duracion - 1), new Date(ini.getTime() - 1));

  const categorias = presupuesto.categorias.map((c) => {
    const gastado = actual.mapa.get(c.categoria_id.toHexString()) || 0;
    return { ...c, gastado: dec(gastado), estado: estado(gastado, num(c.limite), pct) };
  });

  const tendencia = actual.total < anterior.total ? 'mejora' : actual.total > anterior.total ? 'desmejora' : 'igual';
  const set = {
    categorias,
    disponible_para_gastar: dec(num(presupuesto.ingreso_periodo) - actual.total),
    gastado_periodo_anterior: dec(anterior.total),
    tendencia,
    actualizado_en: new Date(),
  };
  await col().updateOne({ _id: presupuesto._id }, { $set: set });

  // Notificación nueva solo cuando una categoría entra en al_limite / excedido.
  for (const c of categorias) {
    if (c.estado === 'cumplido') continue;
    const ya = await db.collection('notificaciones').findOne({ uid, presupuesto_id: presupuesto._id, categoria_id: c.categoria_id, tipo: c.estado });
    if (ya) continue;
    const g = num(c.gastado);
    const l = num(c.limite);
    await db.collection('notificaciones').insertOne({
      uid,
      presupuesto_id: presupuesto._id,
      categoria_id: c.categoria_id,
      tipo: c.estado,
      mensaje:
        c.estado === 'excedido'
          ? `Te pasaste del presupuesto de ${c.nombre_categoria}: llevas ${g.toLocaleString('es-CO')} de ${l.toLocaleString('es-CO')}.`
          : `Estás cerca del límite en ${c.nombre_categoria}: llevas ${g.toLocaleString('es-CO')} de ${l.toLocaleString('es-CO')}.`,
      leida: false,
      creada_en: new Date(),
    });
  }
  return { ...presupuesto, ...set };
}

/** Re-evalúa los presupuestos del usuario que cubren una fecha (se llama tras cada gasto). */
async function evaluarPorFecha(uid, f) {
  const lista = await col().find({ uid, periodo_inicio: { $lte: f }, periodo_fin: { $gte: f } }).toArray();
  for (const p of lista) await evaluar(p);
}

async function categoriasPresupuesto(uid, entrada) {
  if (!Array.isArray(entrada)) throw new HttpError(400, 'categorias debe ser un arreglo [{ categoria_id, limite }]');
  const cats = getDb().collection('categorias');
  const salida = [];
  for (const c of entrada) {
    const cat = await cats.findOne({ _id: oid(c.categoria_id, 'categoria_id'), $or: [{ uid }, { es_sistema: true }] });
    if (!cat) throw new HttpError(404, `Categoría no encontrada: ${c.categoria_id}`);
    salida.push({ categoria_id: cat._id, nombre_categoria: cat.nombre_categoria, limite: dec(c.limite), gastado: dec(0), estado: 'cumplido' });
  }
  return salida;
}

// GET /api/presupuestos  ?vigentes=true
r.get('/', ah(async (req, res) => {
  const filtro = { uid: req.uid };
  if (req.query.vigentes === 'true') {
    const hoy = new Date();
    Object.assign(filtro, { periodo_inicio: { $lte: hoy }, periodo_fin: { $gte: hoy } });
  }
  res.json(serializar(await col().find(filtro).sort({ periodo_inicio: -1 }).toArray()));
}));

r.get('/:id', ah(async (req, res) => {
  const p = await col().findOne({ _id: oid(req.params.id), uid: req.uid });
  if (!p) throw new HttpError(404, 'Presupuesto no encontrado');
  res.json(serializar(p));
}));

// POST /api/presupuestos
//   { nombre, tipo_periodo, periodo_inicio, periodo_fin, moneda?, ingreso_periodo, categorias: [{ categoria_id, limite }] }
r.post('/', ah(async (req, res) => {
  const b = req.body;
  if (!PERIODOS.includes(b.tipo_periodo)) throw new HttpError(400, `tipo_periodo debe ser: ${PERIODOS.join(', ')}`);
  const ini = fecha(b.periodo_inicio, 'periodo_inicio');
  const fin = fecha(b.periodo_fin, 'periodo_fin');
  if (fin <= ini) throw new HttpError(400, 'periodo_fin debe ser posterior a periodo_inicio');
  const { moneda_principal } = await preferencias(req.uid);
  const ahora = new Date();
  const doc = {
    uid: req.uid,
    nombre: String(b.nombre || 'Presupuesto'),
    tipo_periodo: b.tipo_periodo,
    periodo_inicio: ini,
    periodo_fin: fin,
    moneda: moneda(b.moneda, moneda_principal),
    ingreso_periodo: dec(b.ingreso_periodo),
    disponible_para_gastar: dec(b.ingreso_periodo),
    categorias: await categoriasPresupuesto(req.uid, b.categorias || []),
    gastado_periodo_anterior: dec(0),
    tendencia: 'igual',
    creado_en: ahora,
    actualizado_en: ahora,
  };
  const { insertedId } = await col().insertOne(doc);
  res.status(201).json(serializar(await evaluar({ _id: insertedId, ...doc })));
}));

// PUT /api/presupuestos/:id
r.put('/:id', ah(async (req, res) => {
  const b = req.body;
  const actual = await col().findOne({ _id: oid(req.params.id), uid: req.uid });
  if (!actual) throw new HttpError(404, 'Presupuesto no encontrado');
  const set = {};
  if (b.nombre !== undefined) set.nombre = String(b.nombre);
  if (b.tipo_periodo !== undefined) {
    if (!PERIODOS.includes(b.tipo_periodo)) throw new HttpError(400, `tipo_periodo debe ser: ${PERIODOS.join(', ')}`);
    set.tipo_periodo = b.tipo_periodo;
  }
  if (b.periodo_inicio !== undefined) set.periodo_inicio = fecha(b.periodo_inicio, 'periodo_inicio');
  if (b.periodo_fin !== undefined) set.periodo_fin = fecha(b.periodo_fin, 'periodo_fin');
  if (b.moneda !== undefined) set.moneda = moneda(b.moneda);
  if (b.ingreso_periodo !== undefined) set.ingreso_periodo = dec(b.ingreso_periodo);
  if (b.categorias !== undefined) set.categorias = await categoriasPresupuesto(req.uid, b.categorias);
  await col().updateOne({ _id: actual._id }, { $set: set });
  res.json(serializar(await evaluar({ ...actual, ...set })));
}));

// POST /api/presupuestos/:id/evaluar -> fuerza el recálculo
r.post('/:id/evaluar', ah(async (req, res) => {
  const p = await col().findOne({ _id: oid(req.params.id), uid: req.uid });
  if (!p) throw new HttpError(404, 'Presupuesto no encontrado');
  res.json(serializar(await evaluar(p)));
}));

r.delete('/:id', ah(async (req, res) => {
  const { deletedCount } = await col().deleteOne({ _id: oid(req.params.id), uid: req.uid });
  if (!deletedCount) throw new HttpError(404, 'Presupuesto no encontrado');
  res.json({ ok: true });
}));

module.exports = r;
module.exports.evaluarPorFecha = evaluarPorFecha;

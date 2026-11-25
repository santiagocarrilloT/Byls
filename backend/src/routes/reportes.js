// Reportes con aggregation pipeline (RF-22 a RF-27).
const express = require('express');
const { getDb } = require('../db');
const { num, serializar, filtroFecha, ah } = require('../utils');
const { preferencias, tasaCambio } = require('../movimientos');

const r = express.Router();
const tz = (q) => q.zona_horaria || 'America/Bogota';
const firmado = { $cond: [{ $eq: ['$tipo', 'ingreso'] }, '$monto_base', { $multiply: ['$monto_base', -1] }] };

// GET /api/reportes/resumen ?periodo=Mes (o desde/hasta) ?cuenta_id=
//   -> { ingresos, gastos, balance, cantidad }
r.get('/resumen', ah(async (req, res) => {
  const [fila] = await getDb()
    .collection('transacciones')
    .aggregate([
      { $match: { uid: req.uid, tipo: { $in: ['ingreso', 'gasto'] }, ...filtroFecha(req.query) } },
      {
        $group: {
          _id: null,
          ingresos: { $sum: { $cond: [{ $eq: ['$tipo', 'ingreso'] }, '$monto_base', 0] } },
          gastos: { $sum: { $cond: [{ $eq: ['$tipo', 'gasto'] }, '$monto_base', 0] } },
          cantidad: { $sum: 1 },
        },
      },
    ])
    .toArray();
  const ingresos = num(fila?.ingresos);
  const gastos = num(fila?.gastos);
  res.json({ ingresos, gastos, balance: ingresos - gastos, cantidad: fila?.cantidad || 0 });
}));

// GET /api/reportes/saldo-diario -> [{ fecha, total }]  (reemplaza la tabla totalcuentasdiario)
// Patrimonio total por día = suma de saldos iniciales + ingresos - gastos acumulados.
// Las transferencias no cambian el patrimonio total, por eso no entran.
r.get('/saldo-diario', ah(async (req, res) => {
  const db = getDb();
  const { moneda_principal } = await preferencias(req.uid);
  const cuentas = await db.collection('cuentas').find({ uid: req.uid }).toArray();
  let inicial = 0;
  for (const c of cuentas) {
    const tasa = await tasaCambio(c.moneda, moneda_principal);
    inicial += num(c.saldo_inicial) * (tasa ?? 1);
  }

  const filas = await db
    .collection('transacciones')
    .aggregate([
      { $match: { uid: req.uid, tipo: { $in: ['ingreso', 'gasto'] } } },
      { $group: { _id: { $dateTrunc: { date: '$fecha', unit: 'day', timezone: tz(req.query) } }, neto: { $sum: firmado } } },
      { $sort: { _id: 1 } },
      { $setWindowFields: { sortBy: { _id: 1 }, output: { acumulado: { $sum: '$neto', window: { documents: ['unbounded', 'current'] } } } } },
    ])
    .toArray();

  const desde = req.query.desde ? new Date(req.query.desde) : null;
  const salida = filas
    .map((f) => ({ fecha: f._id, total: inicial + num(f.acumulado) }))
    .filter((f) => !desde || f.fecha >= desde);
  res.json(serializar(salida));
}));

// GET /api/reportes/categorias ?tipo=gasto|ingreso ?periodo= | desde/hasta ?limite=5
//   -> categorías con mayor gasto (RF-22) y datos para el diagrama de pastel (RF-24)
r.get('/categorias', ah(async (req, res) => {
  const tipo = req.query.tipo === 'ingreso' ? 'ingreso' : 'gasto';
  const filas = await getDb()
    .collection('transacciones')
    .aggregate([
      { $match: { uid: req.uid, tipo, ...filtroFecha(req.query) } },
      {
        $group: {
          _id: '$categoria.nombre_categoria',
          categoria_id: { $first: '$categoria.id' },
          color_categoria: { $first: '$categoria.color_categoria' },
          total: { $sum: '$monto_base' },
          cantidad: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
      { $limit: Math.min(Number(req.query.limite) || 50, 200) },
      { $project: { _id: 0, nombre_categoria: { $ifNull: ['$_id', 'Sin categoría'] }, categoria_id: 1, color_categoria: 1, total: 1, cantidad: 1 } },
    ])
    .toArray();
  res.json(serializar(filas));
}));

// GET /api/reportes/gastos-hormiga ?periodo=Mes | desde/hasta
//   Gastos pequeños (monto_base <= umbral) que se repiten al menos N veces (RF-23).
r.get('/gastos-hormiga', ah(async (req, res) => {
  const pref = await preferencias(req.uid);
  const umbral = Number(req.query.umbral ?? pref.umbral_gasto_hormiga);
  const minimo = Number(req.query.frecuencia_minima ?? pref.frecuencia_hormiga_minima);
  const detalle = await getDb()
    .collection('transacciones')
    .aggregate([
      { $match: { uid: req.uid, tipo: 'gasto', ...filtroFecha(req.query) } },
      { $match: { $expr: { $lte: ['$monto_base', { $toDecimal: umbral }] } } },
      {
        $group: {
          _id: { $ifNull: ['$categoria.nombre_categoria', '$descripcion'] },
          total: { $sum: '$monto_base' },
          veces: { $sum: 1 },
          promedio: { $avg: '$monto_base' },
          ultimo: { $max: '$fecha' },
        },
      },
      { $match: { veces: { $gte: minimo } } },
      { $sort: { total: -1 } },
      { $project: { _id: 0, concepto: '$_id', total: 1, veces: 1, promedio: 1, ultimo: 1 } },
    ])
    .toArray();
  const total = detalle.reduce((a, d) => a + num(d.total), 0);
  res.json(serializar({ umbral, frecuencia_minima: minimo, moneda: pref.moneda_principal, total_acumulado: total, detalle }));
}));

// GET /api/reportes/evolucion-presupuestal -> histórico de presupuestos con su tendencia (RF-25, RF-26)
r.get('/evolucion-presupuestal', ah(async (req, res) => {
  const filas = await getDb()
    .collection('presupuestos')
    .aggregate([
      { $match: { uid: req.uid } },
      { $sort: { periodo_inicio: 1 } },
      {
        $project: {
          nombre: 1,
          periodo_inicio: 1,
          periodo_fin: 1,
          ingreso_periodo: 1,
          gastado: { $sum: '$categorias.gastado' },
          limite_total: { $sum: '$categorias.limite' },
          gastado_periodo_anterior: 1,
          tendencia: 1,
          categorias_excedidas: { $size: { $filter: { input: '$categorias', cond: { $eq: ['$$this.estado', 'excedido'] } } } },
        },
      },
    ])
    .toArray();
  res.json(serializar(filas));
}));

module.exports = r;

const express = require('express');
const { getDb } = require('../db');
const { HttpError, oid, tipoMovimiento, serializar, ah } = require('../utils');

const r = express.Router();
const col = () => getDb().collection('categorias');

// GET /api/categorias  ?tipo=ingreso|gasto  ?solo_usuario=true (sin las del sistema)
r.get('/', ah(async (req, res) => {
  const filtro = req.query.solo_usuario === 'true' ? { uid: req.uid } : { $or: [{ uid: req.uid }, { es_sistema: true }] };
  if (req.query.tipo) filtro.tipo_categoria = tipoMovimiento(req.query.tipo);
  const lista = await col().find(filtro).sort({ es_sistema: -1, nombre_categoria: 1 }).toArray();
  res.json(serializar(lista));
}));

// POST /api/categorias { nombre_categoria, tipo_categoria, icono_categoria, color_categoria }
r.post('/', ah(async (req, res) => {
  const b = req.body;
  if (!b.nombre_categoria) throw new HttpError(400, 'nombre_categoria es requerido');
  const doc = {
    uid: req.uid,
    es_sistema: false,
    nombre_categoria: String(b.nombre_categoria).trim(),
    tipo_categoria: tipoMovimiento(b.tipo_categoria),
    icono_categoria: String(b.icono_categoria || ''),
    color_categoria: String(b.color_categoria || '0xFF9E9E9E'),
  };
  const { insertedId } = await col().insertOne(doc);
  res.status(201).json(serializar({ _id: insertedId, ...doc }));
}));

// PUT /api/categorias/:id -> solo categorías propias. Actualiza también la copia
// embebida en transacciones (nombre y color) para que los reportes sigan cuadrando.
r.put('/:id', ah(async (req, res) => {
  const b = req.body;
  const actual = await col().findOne({ _id: oid(req.params.id), uid: req.uid });
  if (!actual) throw new HttpError(404, 'Categoría no encontrada (las del sistema no se pueden editar)');
  const set = {};
  if (b.nombre_categoria !== undefined) set.nombre_categoria = String(b.nombre_categoria).trim();
  if (b.tipo_categoria !== undefined) set.tipo_categoria = tipoMovimiento(b.tipo_categoria);
  if (b.icono_categoria !== undefined) set.icono_categoria = String(b.icono_categoria);
  if (b.color_categoria !== undefined) set.color_categoria = String(b.color_categoria);
  await col().updateOne({ _id: actual._id }, { $set: set });
  if (set.nombre_categoria || set.color_categoria) {
    const emb = {};
    if (set.nombre_categoria) emb['categoria.nombre_categoria'] = set.nombre_categoria;
    if (set.color_categoria) emb['categoria.color_categoria'] = set.color_categoria;
    await getDb().collection('transacciones').updateMany({ uid: req.uid, 'categoria.id': actual._id }, { $set: emb });
  }
  res.json(serializar({ ...actual, ...set }));
}));

// DELETE /api/categorias/:id -> solo propias. Las transacciones conservan la copia embebida.
r.delete('/:id', ah(async (req, res) => {
  const { deletedCount } = await col().deleteOne({ _id: oid(req.params.id), uid: req.uid, es_sistema: false });
  if (!deletedCount) throw new HttpError(404, 'Categoría no encontrada (las del sistema no se pueden borrar)');
  res.json({ ok: true });
}));

module.exports = r;

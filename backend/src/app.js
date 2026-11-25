const express = require('express');
const cors = require('cors');
const { MongoServerError } = require('mongodb');
const { autenticar, proveedor } = require('./auth');
const { HttpError } = require('./utils');
const { notificaciones, prefs, tasas } = require('./routes/otros');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/salud', (_req, res) => res.json({ ok: true, auth: proveedor }));

// Registro, login y recuperación de contraseña (públicas; /yo y /cambiar-password piden sesión)
app.use('/api/auth', require('./routes/auth'));

const api = express.Router();
api.use(autenticar);
api.use('/cuentas', require('./routes/cuentas'));
api.use('/categorias', require('./routes/categorias'));
api.use('/transacciones', require('./routes/transacciones'));
api.use('/transferencias', require('./routes/transferencias'));
api.use('/presupuestos', require('./routes/presupuestos'));
api.use('/reportes', require('./routes/reportes'));
api.use('/notificaciones', notificaciones);
api.use('/preferencias', prefs);
api.use('/tasas-cambio', tasas);
app.use('/api', api);

app.use((_req, res) => res.status(404).json({ error: 'Ruta no encontrada' }));

// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  if (err instanceof HttpError) return res.status(err.status).json({ error: err.message });
  if (err instanceof MongoServerError && err.code === 121) {
    return res.status(400).json({ error: 'El documento no cumple el esquema de la colección', detalle: err.errInfo?.details });
  }
  if (err instanceof MongoServerError && err.code === 11000) {
    return res.status(409).json({ error: 'Registro duplicado', detalle: err.keyValue });
  }
  if (err.type === 'entity.parse.failed') return res.status(400).json({ error: 'JSON inválido' });
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
});

module.exports = app;

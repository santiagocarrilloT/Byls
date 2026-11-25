// Autenticación propia sobre MongoDB (RF-01, RF-02, RF-03), sin Supabase.
// Contraseñas cifradas con bcrypt y sesiones con token JWT.
const crypto = require('node:crypto');
const express = require('express');
const bcrypt = require('bcryptjs');
const { getDb } = require('../db');
const { HttpError, ah } = require('../utils');
const { firmarToken, autenticar } = require('../auth');

const r = express.Router();
const usuarios = () => getDb().collection('usuarios');

const MIN_PASSWORD = 6;
const MINUTOS_CODIGO = 15;

function limpiarEmail(email) {
  const e = String(email || '').trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(e)) throw new HttpError(400, 'Correo inválido');
  return e;
}

function validarPassword(password) {
  if (typeof password !== 'string' || password.length < MIN_PASSWORD) {
    throw new HttpError(400, `La contraseña debe tener al menos ${MIN_PASSWORD} caracteres`);
  }
  return password;
}

const respuestaSesion = (u) => ({ token: firmarToken(u), usuario: { id: u._id.toHexString(), email: u.email } });

// POST /api/auth/registro { email, password } -> { token, usuario }
r.post('/registro', ah(async (req, res) => {
  const email = limpiarEmail(req.body.email);
  const password = validarPassword(req.body.password);
  const doc = {
    email,
    password_hash: await bcrypt.hash(password, 10),
    codigo_recuperacion_hash: null,
    codigo_recuperacion_expira: null,
    creado_en: new Date(),
    ultimo_acceso: new Date(),
  };
  try {
    const { insertedId } = await usuarios().insertOne(doc);
    res.status(201).json(respuestaSesion({ _id: insertedId, ...doc }));
  } catch (e) {
    if (e.code === 11000) throw new HttpError(409, 'Ese correo ya está registrado');
    throw e;
  }
}));

// POST /api/auth/login { email, password } -> { token, usuario }
r.post('/login', ah(async (req, res) => {
  const email = limpiarEmail(req.body.email);
  const u = await usuarios().findOne({ email });
  const ok = u && (await bcrypt.compare(String(req.body.password || ''), u.password_hash));
  if (!ok) throw new HttpError(401, 'Correo o contraseña incorrectos');
  await usuarios().updateOne({ _id: u._id }, { $set: { ultimo_acceso: new Date() } });
  res.json(respuestaSesion(u));
}));

// GET /api/auth/yo -> usuario de la sesión actual (sirve para validar el token guardado)
r.get('/yo', autenticar, ah(async (req, res) => {
  res.json({ id: req.uid, email: req.email });
}));

// POST /api/auth/recuperar { email }
// Genera un código de 6 dígitos válido por 15 minutos. Como el proyecto no tiene
// servicio de correo configurado, el código se muestra en la consola del backend.
// Siempre responde lo mismo para no revelar qué correos existen.
r.post('/recuperar', ah(async (req, res) => {
  const email = limpiarEmail(req.body.email);
  const u = await usuarios().findOne({ email });
  if (u) {
    const codigo = String(crypto.randomInt(0, 1_000_000)).padStart(6, '0');
    await usuarios().updateOne(
      { _id: u._id },
      { $set: { codigo_recuperacion_hash: await bcrypt.hash(codigo, 10), codigo_recuperacion_expira: new Date(Date.now() + MINUTOS_CODIGO * 60_000) } }
    );
    console.log(`\n🔑 Código de recuperación para ${email}: ${codigo} (vence en ${MINUTOS_CODIGO} min)\n`);
  }
  res.json({ ok: true, mensaje: 'Si el correo está registrado, se generó un código de recuperación.' });
}));

// POST /api/auth/verificar-codigo { email, codigo } -> { token, usuario }
// Inicia sesión con el código; luego la app llama a /cambiar-password.
r.post('/verificar-codigo', ah(async (req, res) => {
  const email = limpiarEmail(req.body.email);
  const u = await usuarios().findOne({ email });
  const vigente = u?.codigo_recuperacion_hash && u.codigo_recuperacion_expira > new Date();
  const ok = vigente && (await bcrypt.compare(String(req.body.codigo || '').trim(), u.codigo_recuperacion_hash));
  if (!ok) throw new HttpError(400, 'Código incorrecto o vencido');
  await usuarios().updateOne({ _id: u._id }, { $set: { codigo_recuperacion_hash: null, codigo_recuperacion_expira: null, ultimo_acceso: new Date() } });
  res.json(respuestaSesion(u));
}));

// POST /api/auth/cambiar-password { nueva } (requiere sesión)
r.post('/cambiar-password', autenticar, ah(async (req, res) => {
  const nueva = validarPassword(req.body.nueva);
  await usuarios().updateOne({ email: req.email }, { $set: { password_hash: await bcrypt.hash(nueva, 10) } });
  res.json({ ok: true });
}));

module.exports = r;

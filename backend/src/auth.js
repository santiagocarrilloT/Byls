// Middleware de autenticación. Deja el id del usuario en req.uid.
// RF-04: cada usuario solo accede a sus propios datos -> todas las consultas filtran por req.uid.
const jwt = require('jsonwebtoken');
const { HttpError } = require('./utils');

//   mongo    -> usuarios propios en la colección "usuarios" + token JWT (por defecto)
//   firebase -> ID token de Firebase Authentication (opcional, por si luego se cambia)
//   dev      -> confía en el header x-user-id (SOLO para pruebas locales)
const proveedor = (process.env.AUTH_PROVIDER || 'mongo').toLowerCase();
const DURACION = process.env.JWT_DURACION || '30d';

function secreto() {
  const s = process.env.JWT_SECRET;
  if (!s || s.length < 32) throw new HttpError(500, 'Falta JWT_SECRET en .env (mínimo 32 caracteres)');
  return s;
}

function firmarToken(usuario) {
  return jwt.sign({ email: usuario.email }, secreto(), { subject: usuario._id.toHexString(), expiresIn: DURACION });
}

let firebaseAuth;
async function uidDesdeFirebase(token) {
  if (!firebaseAuth) {
    let admin;
    try {
      admin = require('firebase-admin');
    } catch {
      throw new HttpError(500, 'Instala firebase-admin para usar AUTH_PROVIDER=firebase');
    }
    if (!admin.apps.length) admin.initializeApp({ credential: admin.credential.applicationDefault() });
    firebaseAuth = admin.auth();
  }
  try {
    const d = await firebaseAuth.verifyIdToken(token);
    return { uid: d.uid, email: d.email };
  } catch {
    throw new HttpError(401, 'Token de Firebase inválido o vencido');
  }
}

async function autenticar(req, _res, next) {
  try {
    if (proveedor === 'dev') {
      const uid = req.get('x-user-id');
      if (!uid) throw new HttpError(401, 'Modo dev: envía el header x-user-id');
      req.uid = uid;
      req.email = `${uid}@dev.local`;
      return next();
    }

    const header = req.get('authorization') || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new HttpError(401, 'Inicia sesión para continuar');

    if (proveedor === 'firebase') {
      Object.assign(req, await uidDesdeFirebase(token));
      return next();
    }

    try {
      const datos = jwt.verify(token, secreto());
      req.uid = datos.sub;
      req.email = datos.email;
    } catch (e) {
      if (e instanceof HttpError) throw e;
      throw new HttpError(401, 'Sesión inválida o vencida, vuelve a iniciar sesión');
    }
    next();
  } catch (e) {
    next(e);
  }
}

module.exports = { autenticar, firmarToken, proveedor };

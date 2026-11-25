const { ObjectId, Decimal128 } = require('mongodb');

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

/** Convierte un número/texto a Decimal128 (los montos van en Decimal128 por exactitud). */
function dec(valor) {
  if (valor instanceof Decimal128) return valor;
  if (valor === null || valor === undefined || valor === '') throw new HttpError(400, 'Monto requerido');
  const n = Number(valor);
  if (!Number.isFinite(n)) throw new HttpError(400, `Monto inválido: ${valor}`);
  // Redondeo a 6 decimales para evitar basura de punto flotante (0.1 + 0.2).
  return Decimal128.fromString(n.toFixed(6).replace(/\.?0+$/, '') || '0');
}

function decONull(valor) {
  return valor === null || valor === undefined || valor === '' ? null : dec(valor);
}

/** Decimal128 -> number (para responder JSON y hacer cálculos simples). */
function num(valor) {
  if (valor === null || valor === undefined) return 0;
  if (valor instanceof Decimal128) return Number(valor.toString());
  return Number(valor);
}

function oid(valor, campo = 'id') {
  if (valor instanceof ObjectId) return valor;
  if (typeof valor !== 'string' || !ObjectId.isValid(valor)) throw new HttpError(400, `${campo} inválido`);
  return new ObjectId(valor);
}

function oidONull(valor, campo) {
  return valor === null || valor === undefined || valor === '' ? null : oid(valor, campo);
}

function fecha(valor, campo = 'fecha') {
  if (valor === undefined || valor === null || valor === '') return new Date();
  const d = new Date(valor);
  if (Number.isNaN(d.getTime())) throw new HttpError(400, `${campo} inválida`);
  return d;
}

function moneda(valor, defecto) {
  const m = String(valor || defecto || '').trim().toUpperCase();
  if (!/^[A-Z]{3}$/.test(m)) throw new HttpError(400, `Moneda inválida (usa ISO 4217, ej. COP, USD): ${valor}`);
  return m;
}

/** "Ingreso" / "GASTO" / "gasto" -> "ingreso" | "gasto" */
function tipoMovimiento(valor) {
  const t = String(valor || '').trim().toLowerCase();
  if (t !== 'ingreso' && t !== 'gasto') throw new HttpError(400, 'tipo debe ser "ingreso" o "gasto"');
  return t;
}

/** Recorre un documento y deja ObjectId como texto, Decimal128 como número y Date como ISO. */
function serializar(valor) {
  if (valor === null || valor === undefined) return valor;
  if (valor instanceof ObjectId) return valor.toHexString();
  if (valor instanceof Decimal128) return Number(valor.toString());
  if (valor instanceof Date) return valor.toISOString();
  if (Array.isArray(valor)) return valor.map(serializar);
  if (typeof valor === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(valor)) out[k] = serializar(v);
    return out;
  }
  return valor;
}

/**
 * Rango de fechas para los filtros de la app: Día, Semana, Mes, Año, Todos
 * (acepta con o sin tilde / mayúsculas). mes es 1-12.
 */
function rangoPeriodo(periodo, { mes, anio, ahora = new Date() } = {}) {
  const p = String(periodo || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase();
  const y = ahora.getFullYear();
  const m = ahora.getMonth();
  switch (p) {
    case 'dia':
      return { desde: new Date(y, m, ahora.getDate()), hasta: ahora };
    case 'semana': {
      const diasDesdeLunes = (ahora.getDay() + 6) % 7;
      const desde = new Date(y, m, ahora.getDate() - diasDesdeLunes);
      return { desde, hasta: new Date(desde.getFullYear(), desde.getMonth(), desde.getDate() + 7, 0, 0, 0, -1) };
    }
    case 'mes': {
      const mm = mes ? Number(mes) - 1 : m;
      const yy = anio ? Number(anio) : y;
      return { desde: new Date(yy, mm, 1), hasta: new Date(yy, mm + 1, 1, 0, 0, 0, -1) };
    }
    case 'ano':
    case 'anio': {
      const yy = anio ? Number(anio) : y;
      return { desde: new Date(yy, 0, 1), hasta: new Date(yy + 1, 0, 1, 0, 0, 0, -1) };
    }
    case '':
    case 'todos':
      return null;
    default:
      throw new HttpError(400, `Periodo no válido: ${periodo}`);
  }
}

/** Arma el filtro de fecha a partir de ?periodo= o ?desde=&hasta= */
function filtroFecha(query, campo = 'fecha') {
  let desde = query.desde ? fecha(query.desde, 'desde') : null;
  let hasta = query.hasta ? fecha(query.hasta, 'hasta') : null;
  if (query.periodo) {
    const r = rangoPeriodo(query.periodo, { mes: query.mes, anio: query.anio });
    if (r) ({ desde, hasta } = r);
  }
  if (!desde && !hasta) return {};
  const f = {};
  if (desde) f.$gte = desde;
  if (hasta) f.$lte = hasta;
  return { [campo]: f };
}

/** Envuelve un handler async para que los errores lleguen al middleware de errores. */
const ah = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

module.exports = { HttpError, dec, decONull, num, oid, oidONull, fecha, moneda, tipoMovimiento, serializar, rangoPeriodo, filtroFecha, ah };

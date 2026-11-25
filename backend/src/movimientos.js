// Lógica compartida de movimientos: saldo de cuentas, moneda base, tasas y categorías.
const { client, getDb } = require('./db');
const { HttpError, dec, num, oid } = require('./utils');

/** Ejecuta fn dentro de una sesión transaccional de MongoDB (todo o nada). */
async function enTransaccion(fn) {
  const session = client.startSession();
  try {
    let resultado;
    await session.withTransaction(async () => {
      resultado = await fn(session);
    });
    return resultado;
  } finally {
    await session.endSession();
  }
}

async function preferencias(uid, session) {
  const p = await getDb().collection('preferencias_usuario').findOne({ uid }, { session });
  return {
    moneda_principal: p?.moneda_principal || process.env.MONEDA_BASE_DEFECTO || 'COP',
    umbral_gasto_hormiga: p ? num(p.umbral_gasto_hormiga) : 20000,
    frecuencia_hormiga_minima: p?.frecuencia_hormiga_minima ?? 3,
    porcentaje_alerta_presupuesto: p?.porcentaje_alerta_presupuesto ?? 80,
  };
}

/** Tasa más reciente origen->destino (o la inversa). null si no hay o si son iguales. */
async function tasaCambio(origen, destino, session) {
  if (origen === destino) return null;
  const tasas = getDb().collection('tasas_cambio');
  const directa = await tasas.findOne({ moneda_origen: origen, moneda_destino: destino }, { sort: { fecha: -1 }, session });
  if (directa) return num(directa.tasa);
  const inversa = await tasas.findOne({ moneda_origen: destino, moneda_destino: origen }, { sort: { fecha: -1 }, session });
  if (inversa && num(inversa.tasa) !== 0) return 1 / num(inversa.tasa);
  return null;
}

/** Calcula monto_base / tasa_aplicada para un monto en `monedaMov`. */
async function montoBase(uid, monto, monedaMov, session) {
  const { moneda_principal } = await preferencias(uid, session);
  const tasa = await tasaCambio(monedaMov, moneda_principal, session);
  if (monedaMov !== moneda_principal && tasa === null) {
    // Sin tasa registrada: se guarda el mismo monto y tasa null para no bloquear el registro.
    return { monto_base: dec(monto), moneda_base: moneda_principal, tasa_aplicada: null };
  }
  return {
    monto_base: dec(tasa === null ? monto : monto * tasa),
    moneda_base: moneda_principal,
    tasa_aplicada: tasa === null ? null : dec(tasa),
  };
}

async function cuentaDelUsuario(uid, cuentaId, session) {
  const cuenta = await getDb().collection('cuentas').findOne({ _id: oid(cuentaId, 'cuenta_id'), uid }, { session });
  if (!cuenta) throw new HttpError(404, 'Cuenta no encontrada');
  return cuenta;
}

/** Categoría embebida {id, nombre_categoria, color_categoria} a partir de id o nombre. */
async function resolverCategoria(uid, { categoria_id, nombre_categoria, tipo }, session) {
  const cats = getDb().collection('categorias');
  const visibles = { $or: [{ uid }, { es_sistema: true }] };
  let cat = null;
  if (categoria_id) {
    cat = await cats.findOne({ _id: oid(categoria_id, 'categoria_id'), ...visibles }, { session });
    if (!cat) throw new HttpError(404, 'Categoría no encontrada');
  } else if (nombre_categoria) {
    // Primero la del usuario, luego la del sistema; si hay tipo, se prefiere la del mismo tipo.
    const candidatas = await cats.find({ nombre_categoria, ...visibles }, { session }).toArray();
    candidatas.sort((a, b) => (b.uid === uid) - (a.uid === uid) || (b.tipo_categoria === tipo) - (a.tipo_categoria === tipo));
    cat = candidatas[0] || null;
    if (!cat) {
      // La app tiene categorías fijas en código que quizá no estén en la BD: se guarda solo el nombre.
      return { id: null, nombre_categoria, color_categoria: '0xFF9E9E9E' };
    }
  } else {
    return null;
  }
  return { id: cat._id, nombre_categoria: cat.nombre_categoria, color_categoria: cat.color_categoria || '0xFF9E9E9E' };
}

/** +monto para ingreso, -monto para gasto. */
function signo(tipo) {
  if (tipo === 'ingreso') return 1;
  if (tipo === 'gasto') return -1;
  throw new HttpError(400, `Tipo sin efecto directo en saldo: ${tipo}`);
}

async function moverSaldo(cuentaId, delta, session) {
  if (delta === 0) return;
  await getDb()
    .collection('cuentas')
    .updateOne({ _id: cuentaId }, { $inc: { saldo: dec(delta) }, $set: { actualizada_en: new Date() } }, { session });
}

module.exports = { enTransaccion, preferencias, tasaCambio, montoBase, cuentaDelUsuario, resolverCategoria, signo, moverSaldo };

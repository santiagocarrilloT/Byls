// Prueba de punta a punta. Requiere un MongoDB con replica set (las sesiones transaccionales lo exigen):
//   MONGODB_URI="mongodb://127.0.0.1:27017/?replicaSet=rs0" MONGODB_DB=finanzas_test AUTH_PROVIDER=dev npm test
// Usa una base de datos de prueba aparte; NO la apuntes a "finanzas" de producción.
process.env.AUTH_PROVIDER = 'mongo';
process.env.JWT_SECRET = 'secreto-de-prueba-'.padEnd(64, 'x');
const test = require('node:test');
const assert = require('node:assert/strict');
const { connect, close, getDb } = require('../src/db');
const app = require('../src/app');

let base, server, TOKEN, TOKEN_OTRO;
async function api(metodo, ruta, cuerpo, token = TOKEN) {
  const headers = { 'content-type': 'application/json' };
  if (token) headers.authorization = `Bearer ${token}`;
  const r = await fetch(base + ruta, { method: metodo, headers, body: cuerpo ? JSON.stringify(cuerpo) : undefined });
  const json = await r.json();
  return { status: r.status, json };
}

test.before(async () => {
  if (!/test/.test(process.env.MONGODB_DB || '')) throw new Error('Usa MONGODB_DB=finanzas_test para correr las pruebas');
  await connect();
  await getDb().dropDatabase();
  const { execFileSync } = require('node:child_process');
  execFileSync(process.execPath, [require.resolve('../scripts/init-db.js')], { env: process.env, stdio: 'ignore' });
  server = app.listen(0);
  base = `http://127.0.0.1:${server.address().port}/api`;
});
test.after(async () => { server.close(); await close(); });

test('autenticación con usuarios en MongoDB', async () => {
  const reg = await api('POST', '/auth/registro', { email: 'Ana@Correo.com', password: 'secreta1' }, null);
  assert.equal(reg.status, 201);
  assert.equal(reg.json.usuario.email, 'ana@correo.com');
  TOKEN = reg.json.token;
  assert.equal((await api('POST', '/auth/registro', { email: 'ana@correo.com', password: 'otra123' }, null)).status, 409);
  assert.equal((await api('POST', '/auth/registro', { email: 'b@c.com', password: '123' }, null)).status, 400);
  assert.equal((await api('POST', '/auth/login', { email: 'ana@correo.com', password: 'mala' }, null)).status, 401);
  const login = await api('POST', '/auth/login', { email: 'ana@correo.com', password: 'secreta1' }, null);
  assert.equal(login.status, 200);
  assert.equal((await api('GET', '/auth/yo')).json.email, 'ana@correo.com');
  assert.equal((await api('GET', '/cuentas', null, null)).status, 401, 'sin token no entra');
  assert.equal((await api('GET', '/cuentas', null, 'token-falso')).status, 401);
  const db = getDb();
  const guardado = await db.collection('usuarios').findOne({ email: 'ana@correo.com' });
  assert.ok(guardado.password_hash.startsWith('$2'), 'la contraseña se guarda cifrada');

  // recuperar contraseña: el código sale en consola; aquí lo forzamos conocido
  assert.equal((await api('POST', '/auth/recuperar', { email: 'ana@correo.com' }, null)).status, 200);
  const bcrypt = require('bcryptjs');
  await db.collection('usuarios').updateOne({ email: 'ana@correo.com' }, { $set: { codigo_recuperacion_hash: await bcrypt.hash('123456', 4) } });
  assert.equal((await api('POST', '/auth/verificar-codigo', { email: 'ana@correo.com', codigo: '000000' }, null)).status, 400);
  const v = await api('POST', '/auth/verificar-codigo', { email: 'ana@correo.com', codigo: '123456' }, null);
  assert.equal(v.status, 200);
  assert.equal((await api('POST', '/auth/cambiar-password', { nueva: 'nueva123' }, v.json.token)).status, 200);
  assert.equal((await api('POST', '/auth/login', { email: 'ana@correo.com', password: 'nueva123' }, null)).status, 200);
  assert.equal((await api('POST', '/auth/verificar-codigo', { email: 'ana@correo.com', codigo: '123456' }, null)).status, 400, 'el código es de un solo uso');

  TOKEN_OTRO = (await api('POST', '/auth/registro', { email: 'otro@correo.com', password: 'secreta2' }, null)).json.token;
});

test('flujo completo: cuentas, movimientos, transferencias, reportes y presupuestos', async () => {
  const a = (await api('POST', '/cuentas', { nombre_cuenta: 'Bancolombia', saldo: 1000000, moneda: 'COP', icono_cuenta: 'bank' })).json;
  const b = (await api('POST', '/cuentas', { nombre_cuenta: 'Nequi', saldo: 0, moneda: 'COP', tipo_cuenta: 'billetera' })).json;
  assert.equal(a.saldo, 1000000);

  const g = await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'Gasto', monto: 50000, descripcion: 'Almuerzo', nombre_categoria: 'Alimentación', fecha: new Date().toISOString() });
  assert.equal(g.status, 201);
  assert.equal(g.json.categoria.nombre_categoria, 'Alimentación');
  assert.ok(g.json.categoria.id, 'la categoría del sistema se resolvió por nombre');
  await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'ingreso', monto: 200000, nombre_categoria: 'Salario' });
  assert.equal((await api('GET', `/cuentas/${a._id}/saldo`)).json.saldo, 1150000);

  // editar: 50.000 -> 80.000 y pasarlo a la otra cuenta
  await api('PUT', `/transacciones/${g.json._id}`, { monto: 80000, cuenta_id: b._id });
  assert.equal((await api('GET', `/cuentas/${a._id}/saldo`)).json.saldo, 1200000);
  assert.equal((await api('GET', `/cuentas/${b._id}/saldo`)).json.saldo, -80000);

  // idempotencia offline
  const o1 = await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'gasto', monto: 3000, id_local: 'tel-1', nombre_categoria: 'Alimentación' });
  const o2 = await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'gasto', monto: 3000, id_local: 'tel-1', nombre_categoria: 'Alimentación' });
  assert.equal(o1.status, 201); assert.equal(o2.status, 200); assert.equal(o1.json._id, o2.json._id);
  // varias sin id_local no chocan con el índice único
  await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'gasto', monto: 4000, nombre_categoria: 'Alimentación' });
  await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'gasto', monto: 5000, nombre_categoria: 'Alimentación' });

  // transferencia
  const t = await api('POST', '/transferencias', { cuenta_origen_id: a._id, cuenta_destino_id: b._id, monto: 100000, descripcion: 'Paso a Nequi' });
  assert.equal(t.status, 201);
  assert.equal((await api('GET', `/cuentas/${a._id}/saldo`)).json.saldo, 1200000 - 3000 - 4000 - 5000 - 100000);
  assert.equal((await api('GET', `/cuentas/${b._id}/saldo`)).json.saldo, 20000);
  assert.equal((await api('GET', `/transacciones?cuenta_id=${a._id}`)).json.length, 4, 'por defecto no lista las transferencias');
  assert.equal((await api('GET', `/transferencias?cuenta_origen_id=${a._id}&periodo=Mes`)).json.length, 1);

  // reportes
  const resumen = (await api('GET', '/reportes/resumen?periodo=Año')).json;
  assert.equal(resumen.gastos, 92000); assert.equal(resumen.ingresos, 200000);
  const saldo = (await api('GET', '/reportes/saldo-diario')).json;
  assert.equal(saldo.at(-1).total, 1000000 + 200000 - 92000);
  const hormiga = (await api('GET', '/reportes/gastos-hormiga?periodo=Año')).json;
  assert.equal(hormiga.total_acumulado, 12000);
  const top = (await api('GET', '/reportes/categorias?periodo=Año')).json;
  assert.equal(top[0].nombre_categoria, 'Alimentación');

  // presupuesto + notificación
  const cats = (await api('GET', '/categorias?tipo=gasto')).json;
  const alim = cats.find((c) => c.nombre_categoria === 'Alimentación');
  const hoy = new Date();
  const p = await api('POST', '/presupuestos', { nombre: 'Mes', tipo_periodo: 'mensual', periodo_inicio: new Date(hoy.getFullYear(), hoy.getMonth(), 1), periodo_fin: new Date(hoy.getFullYear(), hoy.getMonth() + 1, 0, 23, 59), ingreso_periodo: 500000, categorias: [{ categoria_id: alim._id, limite: 90000 }] });
  assert.equal(p.status, 201);
  assert.equal(p.json.categorias[0].gastado, 92000);
  assert.equal(p.json.categorias[0].estado, 'excedido');
  assert.equal(p.json.disponible_para_gastar, 408000);
  const n = (await api('GET', '/notificaciones?leida=false')).json;
  assert.equal(n.length, 1); assert.equal(n[0].tipo, 'excedido');

  // aislamiento entre usuarios (RF-04)
  assert.equal((await api('GET', `/cuentas/${a._id}`, null, TOKEN_OTRO)).status, 404);
  assert.equal((await api('GET', '/cuentas', null, TOKEN_OTRO)).json.length, 0);

  // borrar transferencia y cuenta
  await api('DELETE', `/transferencias/${t.json._id}`);
  assert.equal((await api('GET', `/cuentas/${b._id}/saldo`)).json.saldo, -80000);
  const del = await api('DELETE', `/cuentas/${b._id}`);
  assert.equal(del.json.transacciones_borradas, 1);

  // categorías propias
  const c = await api('POST', '/categorias', { nombre_categoria: 'Gym', tipo_categoria: 'Gasto', icono_categoria: 'fitness_center', color_categoria: '0xFF00BFA5' });
  assert.equal(c.status, 201);
  assert.equal((await api('GET', '/categorias?solo_usuario=true')).json.length, 1);
  assert.equal((await api('DELETE', `/categorias/${alim._id}`)).status, 404, 'no se borran las del sistema');

  // conversión de divisa
  await api('POST', '/cuentas/convertir-divisa', { moneda: 'USD', tasa: 0.00025 });
  const cuentaUsd = (await api('GET', `/cuentas/${a._id}`)).json;
  assert.equal(cuentaUsd.moneda, 'USD');
  assert.equal(cuentaUsd.saldo, 1188000 * 0.00025); // la transferencia borrada devolvió los 100.000

  // validación de entrada
  assert.equal((await api('POST', '/transacciones', { cuenta_id: a._id, tipo: 'regalo', monto: 1 })).status, 400);
  assert.equal((await api('POST', '/transacciones', { cuenta_id: 'abc', tipo: 'gasto', monto: 1 })).status, 400);
});

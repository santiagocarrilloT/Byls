// Crea la base de datos "finanzas" con las colecciones, validadores e índices
// del documento, en el mismo orden del JSON. Se puede correr varias veces:
// si una colección ya existe, actualiza su validador y crea los índices que falten.
//
//   npm run init-db
//
const { connect, close, dbName } = require('../src/db');
const { COLECCIONES, CATEGORIAS_SISTEMA } = require('../src/schema');

async function main() {
  const db = await connect();
  console.log(`Conectado. Base de datos: ${dbName}\n`);

  const existentes = new Set((await db.listCollections({}, { nameOnly: true }).toArray()).map((c) => c.name));

  for (const col of COLECCIONES) {
    const validacion = { validator: { $jsonSchema: col.validador }, validationLevel: 'strict', validationAction: 'error' };
    if (existentes.has(col.nombre)) {
      await db.command({ collMod: col.nombre, ...validacion });
      console.log(`• ${col.nombre} (ya existía, validador actualizado)`);
    } else {
      await db.createCollection(col.nombre, validacion);
      console.log(`• ${col.nombre} (creada)`);
    }

    for (const idx of col.indices || []) {
      const name = await db.collection(col.nombre).createIndex(idx.campos, idx.opciones || {});
      console.log(`    índice ${name}${idx.uso ? ` — ${idx.uso}` : ''}${idx.extra ? ' (adicional)' : ''}`);
    }
  }

  // Categorías predefinidas del sistema (RF-13). Upsert para no duplicarlas.
  const categorias = db.collection('categorias');
  let nuevas = 0;
  for (const cat of CATEGORIAS_SISTEMA) {
    const r = await categorias.updateOne(
      { es_sistema: true, uid: null, nombre_categoria: cat.nombre_categoria, tipo_categoria: cat.tipo_categoria },
      { $setOnInsert: cat },
      { upsert: true }
    );
    if (r.upsertedCount) nuevas++;
  }
  console.log(`\nCategorías del sistema: ${nuevas} nuevas, ${CATEGORIAS_SISTEMA.length - nuevas} ya existían.`);
  console.log('Listo ✅');
}

main()
  .catch((err) => {
    console.error('\nError inicializando la base de datos:', err.message);
    if (/ENOTFOUND|querySrv|timed out|Server selection/i.test(err.message)) {
      console.error('Revisa la URI y que tu IP esté permitida en Atlas → Network Access.');
    }
    if (/auth/i.test(err.message)) console.error('Revisa usuario y contraseña de la URI.');
    process.exitCode = 1;
  })
  .finally(close);

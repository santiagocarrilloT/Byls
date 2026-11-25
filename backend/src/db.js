const { MongoClient } = require('mongodb');
require('dotenv').config();

const uri = process.env.MONGODB_URI;
const dbName = process.env.MONGODB_DB || 'finanzas';

if (!uri) {
  throw new Error('Falta MONGODB_URI en el archivo .env (mira .env.example).');
}

const client = new MongoClient(uri, { serverSelectionTimeoutMS: 15000 });
let db;

async function connect() {
  if (!db) {
    await client.connect();
    db = client.db(dbName);
  }
  return db;
}

function getDb() {
  if (!db) throw new Error('La base de datos no está conectada. Llama a connect() primero.');
  return db;
}

async function close() {
  await client.close();
  db = undefined;
}

module.exports = { client, connect, getDb, close, dbName };

const { connect, dbName } = require('./db');
const app = require('./app');

const port = Number(process.env.PORT) || 3000;

connect()
  .then(() => {
    app.listen(port, '0.0.0.0', () => {
      console.log(`API de Byls escuchando en http://localhost:${port} (BD: ${dbName})`);
    });
  })
  .catch((err) => {
    console.error('No se pudo conectar a MongoDB:', err.message);
    console.error('Revisa MONGODB_URI en .env y que tu IP esté permitida en Atlas → Network Access.');
    process.exit(1);
  });

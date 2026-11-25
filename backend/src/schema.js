// Estructura de la base de datos "finanzas", tomada del documento
// "Byls – Sistema de Gestión de Gastos" (sección 4, Modelo de Documentos).
// El orden del arreglo COLECCIONES es el mismo orden del JSON del documento.

const iso4217 = { bsonType: 'string', pattern: '^[A-Z]{3}$', description: 'Código ISO 4217' };
const decimal = { bsonType: 'decimal' };
const decimalONull = { bsonType: ['decimal', 'null'] };
const objectIdONull = { bsonType: ['objectId', 'null'] };

const COLECCIONES = [
  // ---------------- colecciones_modificadas ----------------
  {
    nombre: 'cuentas',
    grupo: 'colecciones_modificadas',
    validador: {
      bsonType: 'object',
      required: ['uid', 'nombre_cuenta', 'tipo_cuenta', 'moneda', 'saldo_inicial', 'saldo', 'creada_en', 'actualizada_en'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: 'string' },
        nombre_cuenta: { bsonType: 'string' },
        tipo_cuenta: { enum: ['tarjeta', 'banco', 'efectivo', 'billetera'] },
        moneda: iso4217,
        icono_cuenta: { bsonType: 'string' },
        saldo_inicial: decimal,
        saldo: decimal,
        creada_en: { bsonType: 'date' },
        actualizada_en: { bsonType: 'date' },
      },
    },
    // El documento no define índices para cuentas; este acelera "mis cuentas".
    indices: [{ campos: { uid: 1 }, opciones: { name: 'uid_1' }, extra: true }],
  },
  {
    nombre: 'transacciones',
    grupo: 'colecciones_modificadas',
    validador: {
      bsonType: 'object',
      required: ['uid', 'cuenta_id', 'tipo', 'monto', 'moneda', 'monto_base', 'moneda_base', 'fecha', 'sincronizada', 'creada_en', 'actualizada_en'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: 'string' },
        cuenta_id: { bsonType: 'objectId' },
        tipo: { enum: ['ingreso', 'gasto', 'transferencia'] },
        monto: decimal,
        moneda: iso4217,
        monto_base: decimal,
        moneda_base: iso4217,
        tasa_aplicada: decimalONull,
        fecha: { bsonType: 'date' },
        descripcion: { bsonType: 'string' },
        categoria: {
          bsonType: ['object', 'null'],
          properties: {
            id: { bsonType: ['objectId', 'null'] },
            nombre_categoria: { bsonType: 'string' },
            color_categoria: { bsonType: 'string' },
          },
        },
        transferencia_id: objectIdONull,
        pago_automatico_id: objectIdONull,
        id_local: { bsonType: ['string', 'null'] },
        sincronizada: { bsonType: 'bool' },
        creada_en: { bsonType: 'date' },
        actualizada_en: { bsonType: 'date' },
      },
    },
    indices: [
      { campos: { uid: 1, cuenta_id: 1, fecha: -1 } },
      { campos: { uid: 1, fecha: -1 } },
      { campos: { uid: 1, 'categoria.id': 1, fecha: -1 } },
      { campos: { uid: 1, tipo: 1, monto_base: 1 }, uso: 'Gastos hormiga' },
      { campos: { transferencia_id: 1 }, opciones: { sparse: true } },
      { campos: { pago_automatico_id: 1 }, opciones: { sparse: true } },
      {
        campos: { uid: 1, id_local: 1 },
        uso: 'Idempotencia en sincronización offline',
        // Único solo cuando id_local es texto: si fuera único "a secas", dos
        // transacciones con id_local = null chocarían entre sí.
        opciones: { unique: true, partialFilterExpression: { id_local: { $type: 'string' } } },
      },
    ],
  },
  {
    nombre: 'transferencias',
    grupo: 'colecciones_modificadas',
    validador: {
      bsonType: 'object',
      required: ['uid', 'cuenta_origen_id', 'cuenta_destino_id', 'monto_origen', 'moneda_origen', 'monto_destino', 'moneda_destino', 'fecha', 'transaccion_salida_id', 'transaccion_entrada_id'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: 'string' },
        cuenta_origen_id: { bsonType: 'objectId' },
        cuenta_destino_id: { bsonType: 'objectId' },
        monto_origen: decimal,
        moneda_origen: iso4217,
        monto_destino: decimal,
        moneda_destino: iso4217,
        tasa_aplicada: decimalONull,
        descripcion: { bsonType: 'string' },
        fecha: { bsonType: 'date' },
        transaccion_salida_id: { bsonType: 'objectId' },
        transaccion_entrada_id: { bsonType: 'objectId' },
      },
    },
    indices: [{ campos: { uid: 1, fecha: -1 }, extra: true }],
  },
  {
    nombre: 'categorias',
    grupo: 'colecciones_modificadas',
    validador: {
      bsonType: 'object',
      required: ['es_sistema', 'nombre_categoria', 'tipo_categoria'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: ['string', 'null'] },
        es_sistema: { bsonType: 'bool' },
        nombre_categoria: { bsonType: 'string' },
        tipo_categoria: { enum: ['ingreso', 'gasto'] },
        icono_categoria: { bsonType: 'string' },
        color_categoria: { bsonType: 'string' },
      },
    },
    indices: [{ campos: { uid: 1, tipo_categoria: 1 }, extra: true }],
  },

  // ---------------- colecciones_nuevas ----------------
  {
    nombre: 'presupuestos',
    grupo: 'colecciones_nuevas',
    validador: {
      bsonType: 'object',
      required: ['uid', 'nombre', 'tipo_periodo', 'periodo_inicio', 'periodo_fin', 'moneda', 'ingreso_periodo', 'disponible_para_gastar', 'categorias', 'creado_en', 'actualizado_en'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: 'string' },
        nombre: { bsonType: 'string' },
        tipo_periodo: { enum: ['semanal', 'mensual', 'personalizado'] },
        periodo_inicio: { bsonType: 'date' },
        periodo_fin: { bsonType: 'date' },
        moneda: iso4217,
        ingreso_periodo: decimal,
        disponible_para_gastar: decimal,
        categorias: {
          bsonType: 'array',
          items: {
            bsonType: 'object',
            required: ['categoria_id', 'nombre_categoria', 'limite', 'gastado', 'estado'],
            properties: {
              categoria_id: { bsonType: 'objectId' },
              nombre_categoria: { bsonType: 'string' },
              limite: decimal,
              gastado: decimal,
              estado: { enum: ['cumplido', 'al_limite', 'excedido'] },
            },
          },
        },
        gastado_periodo_anterior: decimal,
        tendencia: { enum: ['mejora', 'desmejora', 'igual'] },
        creado_en: { bsonType: 'date' },
        actualizado_en: { bsonType: 'date' },
      },
    },
    indices: [{ campos: { uid: 1, periodo_inicio: 1, periodo_fin: 1 } }],
  },
  {
    nombre: 'tasas_cambio',
    grupo: 'colecciones_nuevas',
    validador: {
      bsonType: 'object',
      required: ['moneda_origen', 'moneda_destino', 'tasa', 'fecha'],
      properties: {
        _id: { bsonType: 'objectId' },
        moneda_origen: iso4217,
        moneda_destino: iso4217,
        tasa: decimal,
        fecha: { bsonType: 'date' },
        fuente: { bsonType: 'string' },
      },
    },
    indices: [{ campos: { moneda_origen: 1, moneda_destino: 1, fecha: -1 }, opciones: { unique: true } }],
  },
  {
    nombre: 'notificaciones',
    grupo: 'colecciones_nuevas',
    validador: {
      bsonType: 'object',
      required: ['uid', 'tipo', 'mensaje', 'leida', 'creada_en'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: 'string' },
        presupuesto_id: objectIdONull,
        categoria_id: objectIdONull,
        tipo: { enum: ['al_limite', 'excedido'] },
        mensaje: { bsonType: 'string' },
        leida: { bsonType: 'bool' },
        creada_en: { bsonType: 'date' },
      },
    },
    indices: [{ campos: { uid: 1, leida: 1, creada_en: -1 } }],
  },
  {
    nombre: 'preferencias_usuario',
    grupo: 'colecciones_nuevas',
    validador: {
      bsonType: 'object',
      required: ['uid', 'moneda_principal', 'umbral_gasto_hormiga', 'frecuencia_hormiga_minima', 'porcentaje_alerta_presupuesto', 'actualizado_en'],
      properties: {
        _id: { bsonType: 'objectId' },
        uid: { bsonType: 'string' },
        moneda_principal: iso4217,
        umbral_gasto_hormiga: decimal,
        frecuencia_hormiga_minima: { bsonType: 'int' },
        porcentaje_alerta_presupuesto: { bsonType: 'int', minimum: 1, maximum: 100 },
        actualizado_en: { bsonType: 'date' },
      },
    },
    indices: [{ campos: { uid: 1 }, opciones: { unique: true } }],
  },
];

// Colección adicional (no está en el JSON del documento): reemplaza a Supabase Auth /
// Firebase Auth. Guarda los usuarios de la app con la contraseña cifrada (bcrypt).
const COLECCION_USUARIOS = {
  nombre: 'usuarios',
  grupo: 'autenticacion',
  validador: {
    bsonType: 'object',
    required: ['email', 'password_hash', 'creado_en'],
    properties: {
      _id: { bsonType: 'objectId' },
      email: { bsonType: 'string', pattern: '^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$' },
      password_hash: { bsonType: 'string' },
      codigo_recuperacion_hash: { bsonType: ['string', 'null'] },
      codigo_recuperacion_expira: { bsonType: ['date', 'null'] },
      creado_en: { bsonType: 'date' },
      ultimo_acceso: { bsonType: ['date', 'null'] },
    },
  },
  indices: [{ campos: { email: 1 }, opciones: { unique: true } }],
};
COLECCIONES.push(COLECCION_USUARIOS);

// Categorías del sistema (uid = null, es_sistema = true), tomadas de
// lib/models/categorias.dart. Colores en el formato que ya usa la app (0xFFRRGGBB).
const CATEGORIAS_SISTEMA = [
  ['gasto', 'Casa', 'house', '0xFF2196F3'],
  ['gasto', 'Educación', 'school', '0xFF4CAF50'],
  ['gasto', 'Gasolina', 'local_gas_station', '0xFFF44336'],
  ['gasto', 'Moto', 'motorcycle', '0xFF9C27B0'],
  ['gasto', 'Teléfono', 'phone_android', '0xFFFF9800'],
  ['gasto', 'Alimentación', 'fastfood', '0xFF795548'],
  ['gasto', 'TV', 'movie', '0xFFE91E63'],
  ['gasto', 'Salud', 'local_hospital', '0xFF448AFF'],
  ['gasto', 'Ropa', 'checkroom', '0xFFFFC107'],
  ['gasto', 'Viajes', 'airplanemode_active', '0xFF03A9F4'],
  ['gasto', 'Suscripciones', 'subscriptions', '0xFF673AB7'],
  ['gasto', 'Restaurante', 'local_dining', '0xFFFF7043'],
  ['gasto', 'Transporte', 'directions_bus', '0xFF607D8B'],
  ['gasto', 'Renta', 'apartment', '0xFF8D6E63'],
  ['ingreso', 'Salario', 'attach_money', '0xFF009688'],
  ['ingreso', 'Inversiones', 'trending_up', '0xFFFF9800'],
  ['ingreso', 'Venta', 'store', '0xFF4CAF50'],
  ['ingreso', 'Freelance', 'work', '0xFF3F51B5'],
  ['ingreso', 'Regalos', 'card_giftcard', '0xFFFF5252'],
  ['ingreso', 'Alquiler', 'apartment', '0xFF795548'],
  ['ingreso', 'Bonificaciones', 'star', '0xFFFFEB3B'],
  ['ingreso', 'Intereses', 'account_balance', '0xFF64FFDA'],
  ['ingreso', 'Dividendos', 'paid', '0xFF69F0AE'],
].map(([tipo_categoria, nombre_categoria, icono_categoria, color_categoria]) => ({
  uid: null,
  es_sistema: true,
  nombre_categoria,
  tipo_categoria,
  icono_categoria,
  color_categoria,
}));

module.exports = { COLECCIONES, CATEGORIAS_SISTEMA };

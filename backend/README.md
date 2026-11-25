# Byls · Backend MongoDB

API REST en Node.js + Express sobre MongoDB Atlas (base de datos `finanzas`).
La app de Flutter ya **no usa Supabase para nada**: los datos y también el login
(registro, inicio de sesión, recuperar contraseña) pasan por esta API y viven en MongoDB.

```
Flutter (lib/services/api_service.dart)  ──HTTP──►  backend (Express)  ──►  MongoDB Atlas "finanzas"
         token JWT en Authorization               valida el token y filtra todo por uid
```

## Paso a paso

### 1. Requisitos
- Node.js 18 o superior (`node -v`)
- En **Atlas → Network Access**, agrega tu IP (o `0.0.0.0/0` solo mientras desarrollan).

### 2. Instalar
```bash
cd backend
npm install
```

### 3. Configurar `.env`
Ya viene un `.env` con la URI del cluster. Está en `.gitignore`: **no lo suban a git**.
Si lo pierden, copien `.env.example` a `.env` y llenen `MONGODB_URI`.

### 4. Crear la base de datos (una sola vez)
```bash
npm run init-db
```
Crea `finanzas` con las 8 colecciones del JSON del documento, en el mismo orden,
más la colección `usuarios` para el login:
`cuentas`, `transacciones`, `transferencias`, `categorias`, `presupuestos`, `tasas_cambio`,
`notificaciones`, `preferencias_usuario`. Cada colección tiene su validador `$jsonSchema`
(tipos, `Decimal128` en montos, enums), sus índices y 23 categorías del sistema.
Se puede volver a correr sin dañar nada.

### 5. Levantar la API
```bash
npm run dev      # con recarga automática
# o
npm start
```
Prueben con `http://localhost:3000/salud` → `{"ok":true,...}`

### 6. Correr la app
```bash
flutter pub get
flutter run                       # emulador Android usa http://10.0.2.2:3000/api
flutter run -d chrome             # web usa http://localhost:3000/api
flutter run --dart-define=API_URL=http://IP-DE-TU-PC:3000/api   # celular físico (misma red wifi)
```

## Endpoints

Todas las rutas van bajo `/api` y (menos las de `/api/auth`) piden `Authorization: Bearer <token>`.

| Recurso | Métodos |
|---|---|
| `/cuentas` | `GET` · `POST` · `GET/PUT/DELETE /:id` · `GET /:id/saldo` · `POST /convertir-divisa` |
| `/transacciones` | `GET ?cuenta_id&periodo=Día\|Semana\|Mes\|Año&mes&anio&desde&hasta&tipo` · `POST` · `GET/PUT/DELETE /:id` · `DELETE ?cuenta_id` |
| `/transferencias` | `GET ?cuenta_origen_id&periodo` · `POST` · `GET/DELETE /:id` |
| `/categorias` | `GET ?tipo&solo_usuario=true` · `POST` · `PUT/DELETE /:id` (solo las propias) |
| `/presupuestos` | `GET ?vigentes=true` · `POST` · `GET/PUT/DELETE /:id` · `POST /:id/evaluar` |
| `/reportes` | `GET /resumen` · `/saldo-diario` · `/categorias` · `/gastos-hormiga` · `/evolucion-presupuestal` |
| `/notificaciones` | `GET ?leida=false` · `PATCH /:id/leida` · `POST /leer-todas` · `DELETE /:id` |
| `/preferencias` | `GET` · `PUT` |
| `/tasas-cambio` | `GET ?moneda_origen&moneda_destino` · `POST` |

Reglas importantes:
- **El saldo lo mueve el backend.** Crear, editar o borrar un movimiento o una transferencia
  actualiza `cuentas.saldo` en la misma sesión transaccional, así que la app ya no lo calcula.
- Cada transferencia crea 2 transacciones `tipo: "transferencia"` enlazadas. `GET /transacciones`
  no las muestra a menos que se pida `?incluir_transferencias=true`.
- Cada gasto vuelve a evaluar los presupuestos de esa fecha y crea notificaciones `al_limite` / `excedido`.
- `id_local` vuelve idempotente el `POST /transacciones`, para sincronizar sin conexión sin duplicar.

## Autenticación (usuarios en MongoDB)
Colección adicional `usuarios` (email único + contraseña cifrada con bcrypt). El backend entrega
un token JWT que la app guarda en el dispositivo y envía en `Authorization: Bearer <token>`.

| Ruta | Para qué |
|---|---|
| `POST /api/auth/registro` `{ email, password }` | Crea el usuario y devuelve `{ token, usuario }` |
| `POST /api/auth/login` `{ email, password }` | Inicia sesión |
| `GET /api/auth/yo` | Valida el token guardado |
| `POST /api/auth/recuperar` `{ email }` | Genera un código de 6 dígitos (15 min). **Sale en la consola del backend**, porque no hay servicio de correo configurado |
| `POST /api/auth/verificar-codigo` `{ email, codigo }` | Inicia sesión con el código |
| `POST /api/auth/cambiar-password` `{ nueva }` | Cambia la contraseña (requiere sesión) |

`.env` necesita `AUTH_PROVIDER=mongo` y `JWT_SECRET` (cadena aleatoria larga y secreta). Generar una:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```
`AUTH_PROVIDER=firebase` queda disponible si luego quieren cumplir RF-01 al pie de la letra.

## Pruebas
Necesitan un MongoDB local con replica set (las sesiones transaccionales lo exigen):
```bash
MONGODB_URI="mongodb://127.0.0.1:27017/?replicaSet=rs0" MONGODB_DB=finanzas_test npm test
```

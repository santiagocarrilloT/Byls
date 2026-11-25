import 'package:byls_app/services/api_service.dart';

class IncomeModel {
  final String idTransaccion; // ObjectId de MongoDB en texto
  final String? idCuenta; // Relaciona con CuentaModel
  final double montoTransaccion;
  final String tipoTransaccion; // 'Ingreso' | 'Gasto'
  final DateTime fechaTransaccion;
  final String? descripcion;
  final String? nombreCategoria;
  final String? idCategoria;
  final String? colorCategoria;

  IncomeModel({
    required this.idTransaccion,
    this.idCuenta,
    required this.montoTransaccion,
    required this.tipoTransaccion,
    required this.fechaTransaccion,
    this.descripcion,
    this.nombreCategoria,
    this.idCategoria,
    this.colorCategoria,
  });

  // Documento de la colección "transacciones" -> IncomeModel
  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    final categoria = map['categoria'] as Map<String, dynamic>?;
    return IncomeModel(
      idTransaccion: map['_id'],
      idCuenta: map['cuenta_id'],
      montoTransaccion: ApiService.aDouble(map['monto']),
      tipoTransaccion: ApiService.capitalizar(map['tipo']),
      fechaTransaccion: DateTime.parse(map['fecha']).toLocal(),
      descripcion: map['descripcion'],
      nombreCategoria: categoria?['nombre_categoria'],
      idCategoria: categoria?['id'],
      colorCategoria: categoria?['color_categoria'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': idTransaccion,
      'cuenta_id': idCuenta,
      'monto': montoTransaccion,
      'tipo': tipoTransaccion.toLowerCase(),
      'fecha': fechaTransaccion.toUtc().toIso8601String(),
      'descripcion': descripcion,
      'nombre_categoria': nombreCategoria,
    };
  }

  bool get esIngreso => tipoTransaccion.toLowerCase() == 'ingreso';

  // Getters usados en home.dart
  DateTime get fecha => fechaTransaccion;
  String get nombreTransaccion => descripcion ?? 'Transacción';
  String get tipo => tipoTransaccion;
  double get monto => montoTransaccion;
  double get cantidadTransaccion => montoTransaccion;

  static List<IncomeModel> _lista(dynamic data) =>
      (data as List<dynamic>).map((t) => IncomeModel.fromMap(t)).toList();

  // Todas las transacciones del usuario
  static Future<List<IncomeModel>> getTodasTransacciones() async {
    return _lista(await ApiService.get('/transacciones'));
  }

  // Transacciones de una cuenta
  static Future<List<IncomeModel>> getTransacciones(String idCuenta) async {
    return _lista(await ApiService.get('/transacciones', query: {'cuenta_id': idCuenta}));
  }

  // Periodo: 'Día' | 'Semana' | 'Mes' | 'Año'
  static Future<List<IncomeModel>> getTransaccionesFiltradasPorPeriodo(String periodo) async {
    const validos = ['Día', 'Semana', 'Mes', 'Año'];
    if (!validos.contains(periodo)) throw ArgumentError('Periodo no válido');
    return _lista(await ApiService.get('/transacciones', query: {'periodo': periodo}));
  }

  // Transacciones de una cuenta en un periodo; month (1-12) / year opcionales
  static Future<List<IncomeModel>> transaccionesFiltradasPeriodoPersonalizado(
      String periodo, String cuentaId,
      {int? month, int? year}) async {
    const validos = ['Día', 'Semana', 'Mes', 'Año'];
    return _lista(await ApiService.get('/transacciones', query: {
      'cuenta_id': cuentaId,
      'periodo': validos.contains(periodo) ? periodo : 'Todos',
      'mes': periodo == 'Mes' ? month : null,
      'anio': periodo == 'Año' ? year : null,
    }));
  }
}

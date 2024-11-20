// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomeModel {
  final int idTransaccion;
  final int? idCuenta; // Relaciona con CuentaModel, puede ser null
  final double montoTransaccion;
  final String tipoTransaccion;
  final DateTime fechaTransaccion;
  final String? descripcion; // Puede ser null
  final String? nombreCategoria; // Puede ser null

  IncomeModel({
    required this.idTransaccion,
    this.idCuenta,
    required this.montoTransaccion,
    required this.tipoTransaccion,
    required this.fechaTransaccion,
    this.descripcion,
    this.nombreCategoria,
  });

  // Crear una instancia de IncomeModel desde un Map
  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      idTransaccion: map['id_transaccion'],
      idCuenta: map['id_cuenta'],
      montoTransaccion: (map['monto_transaccion'] as num).toDouble(),
      tipoTransaccion: map['tipo_transaccion'],
      fechaTransaccion: DateTime.parse(map['fecha_transaccion']),
      descripcion: map['descripcion'],
      nombreCategoria: map['nombre_categoria'],
    );
  }

  // Convertir la instancia de IncomeModel a Map
  Map<String, dynamic> toMap() {
    return {
      'id_transaccion': idTransaccion,
      'id_cuenta': idCuenta,
      'monto_transaccion': montoTransaccion,
      'tipo_transaccion': tipoTransaccion,
      'fecha_transaccion': fechaTransaccion.toIso8601String(),
      'descripcion': descripcion,
      'nombre_categoria': nombreCategoria,
    };
  }

  // Getter para saber si es un ingreso
  bool get esIngreso => tipoTransaccion.toLowerCase() == 'ingreso';

  // Agregar getters para las propiedades que se están usando en home.dart
  DateTime get fecha =>
      fechaTransaccion; // Acceder a la fecha de la transacción
  String get nombreTransaccion =>
      descripcion ?? 'Transacción'; // Descripción como nombre
  String get tipo => tipoTransaccion; // Tipo de transacción
  double get monto => montoTransaccion; // Monto de la transacción
  double get cantidadTransaccion => montoTransaccion; // Agregar este getter

  // Método para traer todas las transacciones
  static Future<List<IncomeModel>> getTodasTransacciones() async {
    final response =
        await Supabase.instance.client.from('transacciones').select();

    final List<dynamic> data = response;
    return data.map((transaccion) => IncomeModel.fromMap(transaccion)).toList();
  }

  // Método para traer las transacciones filtradas por idCuenta
  static Future<List<IncomeModel>> getTransacciones(int idCuenta) async {
    final response = await Supabase.instance.client
        .from('transacciones')
        .select()
        .eq('id_cuenta', idCuenta); // Filtrando por id_cuenta

    final List<dynamic> data = response;
    return data.map((transaccion) => IncomeModel.fromMap(transaccion)).toList();
  }

  static Future<List<IncomeModel>> getTransaccionesFiltradasPorPeriodo(
      String periodo) async {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (periodo) {
      case 'Día':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Año':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        throw ArgumentError('Periodo no válido');
    }

    final response = await Supabase.instance.client
        .from('transacciones')
        .select()
        .gte('fecha_transaccion', startDate.toIso8601String())
        .lte('fecha_transaccion', now.toIso8601String());

    final List<dynamic> data = response;
    return data.map((transaccion) => IncomeModel.fromMap(transaccion)).toList();
  }

  // Nuevo: Método para traer transacciones filtradas por periodo
  static Future<List<IncomeModel>> transaccionesFiltradasPeriodoPersonalizado(
      String periodo, int cuentaId,
      {int? month, int? year}) async {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (periodo == 'Mes' && month != null) {
      startDate = DateTime(now.year, month, 1);
      endDate =
          DateTime(now.year, month + 1, 1).subtract(const Duration(days: 1));
    } else if (periodo == 'Año' && year != null) {
      startDate = DateTime(year, 1, 1);
      endDate = DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));
    } else if (periodo == 'Día') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = now;
    } else if (periodo == 'Semana') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = startDate.add(const Duration(days: 6));
    } else {
      startDate = DateTime(1970); // Para "Todos"
      endDate = now;
    }

    final response = await Supabase.instance.client
        .from('transacciones')
        .select()
        .eq('id_cuenta', cuentaId)
        .gte('fecha_transaccion', startDate.toIso8601String())
        .lte('fecha_transaccion', endDate.toIso8601String());

    final List<dynamic> data = response;
    return data.map((transaccion) => IncomeModel.fromMap(transaccion)).toList();
  }
}

// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byls_app/models/user_model.dart';

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

  // Crear una instancia de TransaccionModel desde un Map
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

  // Convertir la instancia de TransaccionModel a Map
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

  // Método para traer las transacciones filtradas por idCuenta
  static Future<List<IncomeModel>> getTransacciones(int idCuenta) async {
    final response = await Supabase.instance.client
        .from('transacciones')
        .select()
        .eq('id_cuenta', idCuenta); // Filtrando por id_cuenta

    //Ver el tipo de datos de response
    //print(response.runtimeType);
    final List<dynamic> data = response;
    return data.map((transaccion) => IncomeModel.fromMap(transaccion)).toList();
  }
}

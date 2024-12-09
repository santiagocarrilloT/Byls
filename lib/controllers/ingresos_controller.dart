import 'package:supabase_flutter/supabase_flutter.dart';

class IngresosController {
  // Función para insertar una transacción
  Future<void> insertarTransaccion(
      String idCuenta,
      String descripcion,
      String nombreCategoria,
      double montoTransaccion,
      String tipoTransaccion,
      DateTime fechaTransaccion) async {
    await Supabase.instance.client.from('transacciones').insert(
      {
        'id_cuenta': idCuenta,
        'descripcion': descripcion,
        'monto_transaccion': montoTransaccion,
        'tipo_transaccion': tipoTransaccion,
        'fecha_transaccion': fechaTransaccion.toIso8601String(),
        'nombre_categoria': nombreCategoria,
        // 'id_cuenta': idCuenta, // Añádelo cuando tengas el id_cuenta
      },
    );
  }

  Future<void> updateIngreso(
    String idCuenta,
    String idIngreso,
    String descripcion,
    double montoTransaccion,
    String tipoTransaccion,
    DateTime fechaTransaccion,
    String nombreCategoria,
  ) async {
    await Supabase.instance.client.from('transacciones').update({
      'id_cuenta': idCuenta,
      'descripcion': descripcion,
      'monto_transaccion': montoTransaccion,
      'tipo_transaccion': tipoTransaccion,
      'fecha_transaccion': fechaTransaccion.toIso8601String(),
      'nombre_categoria': nombreCategoria,
    }).eq('id_transaccion', idIngreso);
  }

  Future<void> deleteIngreso(String idIngreso) async {
    await Supabase.instance.client
        .from('transacciones')
        .delete()
        .eq('id_transaccion', idIngreso);
  }

  Future<void> deleteIngresoPorCuenta(String idCuenta) async {
    await Supabase.instance.client
        .from('transacciones')
        .delete()
        .eq('id_cuenta', idCuenta);
  }
}

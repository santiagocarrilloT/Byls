import 'package:supabase_flutter/supabase_flutter.dart';

class IngresosController {
  Future<void> createIngreso(String concepto, double monto) async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('ingresos')
        .insert({'concepto': concepto, 'monto': monto, 'user_id': user!.id});
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<void> updateIngreso(
      String idIngreso,
      String idCuenta,
      String nombreCategoria,
      int montoTransaccion,
      String tipoTransaccion,
      String descripcion) async {
    final response =
        await Supabase.instance.client.from('transacciones').update({
      'id_cuenta': idCuenta,
      'nombre_categoria': nombreCategoria,
      'monto_transaccion': montoTransaccion,
      'tipo_transaccion': tipoTransaccion,
      'descripcion': descripcion,
    }).eq('id', idIngreso);
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<void> deleteIngreso(String idIngreso) async {
    final response = await Supabase.instance.client
        .from('transacciones')
        .delete()
        .eq('id_transaccion', idIngreso);
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}

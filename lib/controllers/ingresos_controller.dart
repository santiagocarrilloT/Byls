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
    String descripcion,
    double montoTransaccion,
    String tipoTransaccion,
    DateTime fechaTransaccion,
    String nombreCategoria,
  ) async {
    final response =
        await Supabase.instance.client.from('transacciones').update({
      'descripcion': descripcion,
      'monto_transaccion': montoTransaccion,
      'tipo_transaccion': tipoTransaccion,
      'fecha_transaccion': fechaTransaccion.toIso8601String(),
      'nombre_categoria': nombreCategoria,
    }).eq('id_transaccion', idIngreso);
  }

  Future<void> deleteIngreso(String idIngreso) async {
    final response = await Supabase.instance.client
        .from('transacciones')
        .delete()
        .eq('id_transaccion', idIngreso);
  }
}

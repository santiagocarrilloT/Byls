import 'package:supabase_flutter/supabase_flutter.dart';

class TransferenciaController {
  Future<void> insertarTransferencia(
      String idCuentaOrigen,
      String idCuentaDestino,
      double cantidad,
      String descripcion,
      DateTime fechaTransferencia) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    await Supabase.instance.client.from('transferencias').insert({
      'uid': userId,
      'id_cuentaorigen': idCuentaOrigen,
      'id_cuentadestino': idCuentaDestino,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'fecha_transferencia': fechaTransferencia.toIso8601String(),
    });
  }
}

import 'package:byls_app/services/api_service.dart';

class TransferenciaController {
  // El backend crea la transferencia + las 2 transacciones enlazadas y mueve
  // ambos saldos en una sola sesión transaccional.
  Future<void> insertarTransferencia(
      String idCuentaOrigen,
      String idCuentaDestino,
      double cantidad,
      String descripcion,
      DateTime fechaTransferencia) async {
    await ApiService.post('/transferencias', {
      'cuenta_origen_id': idCuentaOrigen,
      'cuenta_destino_id': idCuentaDestino,
      'monto': cantidad,
      'descripcion': descripcion,
      'fecha': fechaTransferencia.toUtc().toIso8601String(),
    });
  }

  Future<void> deleteTransferencia(String idTransferencia) async {
    await ApiService.delete('/transferencias/$idTransferencia');
  }
}

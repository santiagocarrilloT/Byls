import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/services/api_service.dart';
import 'package:byls_app/services/sesion.dart';

class CambiosDivisaController {
  final double cantidadConversion; // tasa: 1 unidad de la moneda actual = cantidadConversion de la nueva
  final String tipoMoneda; // moneda destino (ISO 4217)
  final usuarioId = Sesion.usuario;

  late final Future<List<CuentaModel>> cuentas;

  CambiosDivisaController({required this.cantidadConversion, required this.tipoMoneda}) {
    cuentas = usuarioId != null ? CuentaModel.getCuentas() : Future.error('Usuario no autenticado');
  }

  // Convierte todas las cuentas y movimientos del usuario en una sola operación
  // del backend (antes se hacía cuenta por cuenta y transacción por transacción).
  Future<void> convertirDivisas() async {
    try {
      await ApiService.post('/cuentas/convertir-divisa', {
        'moneda': tipoMoneda,
        'tasa': cantidadConversion,
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}

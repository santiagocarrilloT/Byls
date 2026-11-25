import 'package:byls_app/services/api_service.dart';

class CuentaController {
  Future<void> createCuenta(
    double saldo,
    String nombre,
    String iconoCategoria,
    String tipoMoneda, {
    String tipoCuenta = 'banco', // tarjeta | banco | efectivo | billetera
  }) async {
    await ApiService.post('/cuentas', {
      'nombre_cuenta': nombre,
      'saldo_inicial': saldo,
      'moneda': tipoMoneda,
      'icono_cuenta': iconoCategoria,
      'tipo_cuenta': tipoCuenta,
    });
  }

  Future<void> updateCuenta(
    double saldo,
    String nombre,
    String iconoCategoria,
    String tipoMoneda,
    String idCuenta,
  ) async {
    await ApiService.put('/cuentas/$idCuenta', {
      'saldo': saldo,
      'nombre_cuenta': nombre,
      'moneda': tipoMoneda,
      'icono_cuenta': iconoCategoria,
    });
  }

  // El backend borra la cuenta, sus movimientos y sus transferencias en una sola operación.
  Future<void> deleteCuenta(String idCuenta) async {
    await ApiService.delete('/cuentas/$idCuenta');
  }

  // ---------------------------------------------------------------------------
  // Los tres métodos siguientes ya NO hacen nada: con MongoDB el backend
  // actualiza el saldo automáticamente (en la misma sesión transaccional) cada
  // vez que se crea, edita o borra un movimiento o una transferencia (RF-07).
  // Se dejan para no romper las pantallas que todavía los llaman; si se
  // mantuvieran activos, el saldo se movería dos veces.
  // ---------------------------------------------------------------------------
  @Deprecated('El backend actualiza el saldo. Se puede borrar la llamada.')
  Future<void> actualizarSaldo(
    double saldo,
    String idCuenta,
    double montoTransaccion,
    bool tipoTransaccion,
  ) async {}

  @Deprecated('El backend actualiza el saldo. Se puede borrar la llamada.')
  Future<void> actualizarSaldoMonto(
    double saldo,
    String idCuenta,
    double montoTransaccionAnterior,
    double montoTransaccionNueva,
    bool tipoTransaccion,
  ) async {}

  @Deprecated('El backend actualiza el saldo. Se puede borrar la llamada.')
  Future<void> actualizarSaldoTipoTransaccion(
    double saldo,
    String idCuenta,
    double montoTransaccionAnterior,
    double montoTransaccionNueva,
    bool tipoTransaccion,
  ) async {}
}

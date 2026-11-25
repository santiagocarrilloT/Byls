import 'package:byls_app/services/api_service.dart';

class IngresosController {
  // Crea un ingreso o gasto. El backend busca la categoría por nombre, calcula
  // monto_base y actualiza el saldo de la cuenta.
  Future<void> insertarTransaccion(
      String idCuenta,
      String descripcion,
      String nombreCategoria,
      double montoTransaccion,
      String tipoTransaccion, // 'Ingreso' | 'Gasto'
      DateTime fechaTransaccion,
      {String? idLocal}) async {
    await ApiService.post('/transacciones', {
      'cuenta_id': idCuenta,
      'descripcion': descripcion,
      'nombre_categoria': nombreCategoria,
      'monto': montoTransaccion,
      'tipo': tipoTransaccion.toLowerCase(),
      'fecha': fechaTransaccion.toUtc().toIso8601String(),
      if (idLocal != null) 'id_local': idLocal,
    });
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
    await ApiService.put('/transacciones/$idIngreso', {
      'cuenta_id': idCuenta,
      'descripcion': descripcion,
      'monto': montoTransaccion,
      'tipo': tipoTransaccion.toLowerCase(),
      'fecha': fechaTransaccion.toUtc().toIso8601String(),
      'nombre_categoria': nombreCategoria,
    });
  }

  Future<void> deleteIngreso(String idIngreso) async {
    await ApiService.delete('/transacciones/$idIngreso');
  }

  Future<void> deleteIngresoPorCuenta(String idCuenta) async {
    await ApiService.delete('/transacciones', query: {'cuenta_id': idCuenta});
  }
}

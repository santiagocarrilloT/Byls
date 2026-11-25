import 'package:flutter/material.dart';
import 'package:byls_app/models/cuenta_model.dart';

class SaldoController extends ChangeNotifier {
  double _saldo = 0.0;

  double get saldo => _saldo;

  // Método para cargar el saldo de una cuenta
  Future<void> cargarSaldo(String idCuenta) async {
    _saldo = await CuentaModel.getSaldoCuenta(idCuenta);
    notifyListeners();
  }
}

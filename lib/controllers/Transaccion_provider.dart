import 'package:byls_app/models/transacciones_model.dart';
import 'package:flutter/material.dart';

class TransaccionProvider extends ChangeNotifier {
  IncomeModel? _currentTransaccion;

  IncomeModel? get currentTransaccion => _currentTransaccion;

  void setCurrentTransaccion(IncomeModel transaccion) {
    _currentTransaccion = transaccion;
    notifyListeners();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class CuentaController {
  Future<void> createCuenta(
    double saldo,
    String nombre,
    String iconoCategoria,
    String tipoMoneda,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }
    await Supabase.instance.client.from('cuentas').insert({
      'uid': user.id,
      'saldo': saldo,
      'nombre_cuenta': nombre,
      'tipo_moneda': tipoMoneda,
      'iconoCuenta': iconoCategoria,
    });
    //print(response.toString());
  }

  Future<void> updateCuenta(
    double saldo,
    String nombre,
    String iconoCategoria,
    String tipoMoneda,
    String idCuenta,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }
    await Supabase.instance.client.from('cuentas').update({
      'saldo': saldo,
      'nombre_cuenta': nombre,
      'tipo_moneda': tipoMoneda,
      'iconoCuenta': iconoCategoria,
    }).eq('idcuenta', idCuenta);
  }

  Future<void> deleteCuenta(String idCuenta) async {
    await Supabase.instance.client
        .from('cuentas')
        .delete()
        .eq('idcuenta', idCuenta);
  }

  Future<void> actualizarSaldo(
    double saldo,
    String idCuenta,
    double montoTransaccion,
    bool tipoTransaccion,
  ) async {
    //Si tipoTransaccion es true, es un ingreso (Suma), si es false, es un egreso (Resta)
    await Supabase.instance.client.from('cuentas').update({
      'saldo': saldo + (tipoTransaccion ? montoTransaccion : -montoTransaccion),
    }).eq('idcuenta', idCuenta);
  }

  Future<void> actualizarSaldoEdit(
    double saldo,
    String idCuenta,
    double montoTransaccion,
    bool tipoTransaccion,
  ) async {
    //Si tipoTransaccion es true, es un ingreso (Suma), si es false, es un egreso (Resta)
    await Supabase.instance.client.from('cuentas').update({
      'saldo': saldo + (tipoTransaccion ? montoTransaccion : -montoTransaccion),
    }).eq('idcuenta', idCuenta);
  }
}

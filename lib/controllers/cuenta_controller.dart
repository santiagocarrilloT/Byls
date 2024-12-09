import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CuentaController {
  IngresosController ingresosController = IngresosController();
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
    ingresosController.deleteIngresoPorCuenta(idCuenta);
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
    print(tipoTransaccion);
    await Supabase.instance.client.from('cuentas').update({
      'saldo': saldo + (tipoTransaccion ? montoTransaccion : -montoTransaccion),
    }).eq('idcuenta', idCuenta);
  }

  Future<void> actualizarSaldoMonto(
    double saldo,
    String idCuenta,
    double montoTransaccionAnterior,
    double montoTransaccionNueva,
    bool tipoTransaccion,
  ) async {
    switch (tipoTransaccion) {
      case true:
        //(Gastos) Si tipoTransaccion es true, primero se suma el monto anterior y luego se resta el nuevo monto
        saldo = saldo + montoTransaccionAnterior;
        saldo = saldo - montoTransaccionNueva;
        break;
      case false:
        //(Ingresos) Si tipoTransaccion es false, primero se resta el monto anterior y luego se suma el nuevo monto
        saldo = saldo - montoTransaccionAnterior;
        saldo = saldo + montoTransaccionNueva;
        break;
    }

    await Supabase.instance.client.from('cuentas').update({
      'saldo': saldo,
    }).eq('idcuenta', idCuenta);
  }

  Future<void> actualizarSaldoTipoTransaccion(
    double saldo,
    String idCuenta,
    double montoTransaccionAnterior,
    double montoTransaccionNueva,
    bool tipoTransaccion,
  ) async {
    switch (tipoTransaccion) {
      case true:
        //(Gastos a Ingresos) Si tipoTransaccion es true, primero se suma el monto anterior y luego se resta el nuevo monto
        saldo = saldo + montoTransaccionAnterior;
        saldo = saldo + montoTransaccionNueva;
        break;
      case false:
        //(Ingresos a Gastos) Si tipoTransaccion es false, primero se resta el monto anterior y luego se suma el nuevo monto
        saldo = saldo - montoTransaccionAnterior;
        saldo = saldo - montoTransaccionNueva;
        break;
    }

    await Supabase.instance.client.from('cuentas').update({
      'saldo': saldo,
    }).eq('idcuenta', idCuenta);
  }
}

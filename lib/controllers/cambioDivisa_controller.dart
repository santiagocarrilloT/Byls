import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CambiosDivisaController {
  final double cantidadConversion;
  final String tipoMoneda;
  final usuarioId = Supabase.instance.client.auth.currentUser;

  late final Future<List<CuentaModel>> cuentas;
  late Future<List<IncomeModel>> transacciones;

  CambiosDivisaController(
      {required this.cantidadConversion, required this.tipoMoneda}) {
    if (usuarioId != null) {
      cuentas = CuentaModel.getCuentas(usuarioId!.id);
    } else {
      cuentas = Future.error('Usuario no autenticado');
    }
  }

  Future<void> convertirDivisas() async {
    try {
      final cuentasList = await cuentas;

      await Future.forEach(cuentasList, (CuentaModel cuentaUsuario) async {
        transacciones = IncomeModel.getTransacciones(cuentaUsuario.idCuenta);

        await conversionCuentas(cuentaUsuario);

        final transaccionesList = await transacciones;
        conversionTransacciones(transaccionesList, cuentaUsuario.idCuenta);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //Conversión de las cuentas
  Future<void> conversionCuentas(CuentaModel cuentaUsuario) async {
    print('Saldo: ${cuentaUsuario.saldo * cantidadConversion}');
    await Supabase.instance.client.from('cuentas').update({
      'tipo_moneda': tipoMoneda,
      'saldo': cuentaUsuario.saldo * cantidadConversion,
    }).eq('idcuenta', cuentaUsuario.idCuenta);
  }

  //Conversión de las transacciones
  Future<void> conversionTransacciones(
      List<IncomeModel> transaccionesList, idCuenta) async {
    transaccionesList.forEach((transaccionesUser) async {
      /* if (transaccionesUser.idTransaccion == 51 && idCuenta == 5) {
        print(
            'M: ${transaccionesUser.montoTransaccion}, T: ${transaccionesUser.idTransaccion}, C: ${idCuenta}, Conv: $cantidadConversion');
        await Supabase.instance.client
            .from('transacciones')
            .update({
              'monto_transaccion':
                  (transaccionesUser.montoTransaccion * cantidadConversion),
            })
            .eq('id_cuenta', idCuenta)
            .eq('id_transaccion', 51);
        print('Transacción actualizada');
      } */
      print('${transaccionesUser.montoTransaccion * cantidadConversion}');
      await Supabase.instance.client.from('transacciones').update({
        'monto_transaccion':
            transaccionesUser.montoTransaccion * cantidadConversion,
      }).eq('id_transaccion', transaccionesUser.idTransaccion.toString());
    });
  }
}

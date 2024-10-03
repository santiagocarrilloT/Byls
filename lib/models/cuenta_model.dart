import 'package:supabase_flutter/supabase_flutter.dart';

class CuentaModel {
  final int idCuenta;
  final String uid;
  final String nombreCuenta;
  final double saldo;
  final String? tipoMoneda;
  final String? icono;

  CuentaModel({
    required this.idCuenta,
    required this.uid,
    required this.nombreCuenta,
    required this.saldo,
    this.tipoMoneda,
    this.icono,
  });

  // Método para convertir un mapa en una instancia de CuentaModel
  factory CuentaModel.fromMap(Map<String, dynamic> map) {
    return CuentaModel(
      idCuenta: map['idcuenta'],
      uid: map['uid'],
      nombreCuenta: map['nombre_cuenta'],
      saldo: map['saldo']?.toDouble() ?? 0.0,
      tipoMoneda: map['tipo_moneda'],
      icono: map['iconoCuenta'],
    );
  }

  // Método para convertir una instancia de CuentaModel en un mapa
  Map<String, dynamic> toMap() {
    return {
      'idcuenta': idCuenta,
      'uid': uid,
      'nombre_cuenta': nombreCuenta,
      'saldo': saldo,
      'tipo_moneda': tipoMoneda,
      'iconoCuenta': icono,
    };
  }

  // Método para obtener las cuentas de un usuario por su UID
  static Future<List<CuentaModel>> getCuentas(String userId) async {
    final cuentas = await Supabase.instance.client
        .from('cuentas')
        .select()
        .eq('uid', userId);

    final List<CuentaModel> cuentasUsuario = [];
    for (final item in cuentas) {
      cuentasUsuario.add(CuentaModel.fromMap(item));
    }
    return cuentasUsuario;
  }
}

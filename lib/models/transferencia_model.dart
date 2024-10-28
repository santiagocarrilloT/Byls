import 'package:supabase_flutter/supabase_flutter.dart';

class TransferenciaModel {
  final int idTransferencia;
  final String uid;
  final String idCuentaOrigen;
  final String idCuentaDestino;
  final double cantidad;
  final String? descripcion;
  final DateTime fechaTransferencia;

  TransferenciaModel({
    required this.idTransferencia,
    required this.uid,
    required this.idCuentaOrigen,
    required this.idCuentaDestino,
    required this.cantidad,
    this.descripcion,
    required this.fechaTransferencia,
  });

  // Método para obtener el saldo de una cuenta específica
/* static Future<double> getSaldoCuenta(int idCuenta) async {
  final response = await Supabase.instance.client
      .from('cuentas')
      .select('saldo')
      .eq('idcuenta', idCuenta)
      .single();  // Obtener solo un resultado

  return (response['saldo'] as num).toDouble();
} */

  // Método para convertir un mapa en una instancia de CuentaModel
  factory TransferenciaModel.fromMap(Map<String, dynamic> map) {
    return TransferenciaModel(
      idTransferencia: map['idtransferencia'],
      uid: map['uid'],
      idCuentaOrigen: map['idcuentaorigen'],
      idCuentaDestino: map['idcuentadestino'],
      cantidad: (map['cantidad'] as num).toDouble(),
      descripcion: map['descripcion'],
      fechaTransferencia: DateTime.parse(map['fecha_transferencia']),
    );
  }

  // Método para convertir una instancia de CuentaModel en un mapa
  Map<String, dynamic> toMap() {
    return {
      'idtransferencia': idTransferencia,
      'uid': uid,
      'idCuentaOrigen': idCuentaOrigen,
      'idCuentaDestino': idCuentaDestino,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'fecha_transferencia': fechaTransferencia.toIso8601String(),
    };
  }

  // Método para obtener las cuentas de un usuario por su UID
  static Future<List<TransferenciaModel>> getTransferencias() async {
    final userId = Supabase.instance.client.auth.currentUser;
    final cuentas = await Supabase.instance.client
        .from('transferencias')
        .select()
        .eq('uid', userId!);

    final List<TransferenciaModel> transferenciasUsuario = [];
    for (final item in cuentas) {
      transferenciasUsuario.add(TransferenciaModel.fromMap(item));
    }
    return transferenciasUsuario;
  }
}

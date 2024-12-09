import 'package:supabase_flutter/supabase_flutter.dart';

class TransferenciaModel {
  final int idTransferencia;
  final String uid;
  final int idCuentaOrigen;
  final int idCuentaDestino;
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

  // Método para convertir un mapa en una instancia de CuentaModel
  factory TransferenciaModel.fromMap(Map<String, dynamic> map) {
    return TransferenciaModel(
      idTransferencia: map['idtransferencia'],
      uid: map['uid'],
      idCuentaOrigen: map['id_cuentaorigen'],
      idCuentaDestino: map['id_cuentadestino'],
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
      'id_cuentaOrigen': idCuentaOrigen,
      'id_cuentaDestino': idCuentaDestino,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'fecha_transferencia': fechaTransferencia.toIso8601String(),
    };
  }

  // Método para obtener las cuentas de un usuario por su UID
  static Future<List<TransferenciaModel>> getTransferencias() async {
    final userId = Supabase.instance.client.auth.currentUser;
    final transferencias = await Supabase.instance.client
        .from('transferencias')
        .select()
        .eq('uid', userId!.id);

    final List<TransferenciaModel> transferenciasUsuario = [];

    for (final item in transferencias) {
      transferenciasUsuario.add(TransferenciaModel.fromMap(item));
    }
    return transferenciasUsuario;
  }

  static Future<List<TransferenciaModel>> cargarTransferenciasPorCuentaOrigen(
      idCuentaOrigen) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final transferencias = await Supabase.instance.client
        .from('transferencias')
        .select()
        .eq('uid', userId!)
        .eq('id_cuentaorigen', idCuentaOrigen);
    //.order('fecha_transferencia', ascending: false);

    final List<TransferenciaModel> transferenciasUsuario = [];

    for (final item in transferencias) {
      transferenciasUsuario.add(TransferenciaModel.fromMap(item));
    }
    return transferenciasUsuario;
  }

  static Future<List<TransferenciaModel>> cargarTransferenciasPorFecha(periodo,
      {int? month, int? year}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    DateTime now = DateTime.now();
    DateTime startDate;

    switch (periodo) {
      case 'Día':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Año':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        throw ArgumentError('Periodo no válido');
    }
    final transferencias = await Supabase.instance.client
        .from('transferencias')
        .select()
        .eq('uid', userId!)
        .gte('fecha_transferencia', startDate.toIso8601String());

    final List<TransferenciaModel> transferenciasUsuario = [];

    for (final item in transferencias) {
      transferenciasUsuario.add(TransferenciaModel.fromMap(item));
    }
    return transferenciasUsuario;
  }
}

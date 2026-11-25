import 'package:byls_app/services/api_service.dart';

class TransferenciaModel {
  final String idTransferencia; // ObjectId de MongoDB en texto
  final String uid;
  final String idCuentaOrigen;
  final String idCuentaDestino;
  final double cantidad; // monto_origen
  final double cantidadDestino; // monto_destino (igual a cantidad si es la misma moneda)
  final String? descripcion;
  final DateTime fechaTransferencia;

  TransferenciaModel({
    required this.idTransferencia,
    required this.uid,
    required this.idCuentaOrigen,
    required this.idCuentaDestino,
    required this.cantidad,
    required this.cantidadDestino,
    this.descripcion,
    required this.fechaTransferencia,
  });

  // Documento de la colección "transferencias" -> TransferenciaModel
  factory TransferenciaModel.fromMap(Map<String, dynamic> map) {
    return TransferenciaModel(
      idTransferencia: map['_id'],
      uid: map['uid'] ?? '',
      idCuentaOrigen: map['cuenta_origen_id'],
      idCuentaDestino: map['cuenta_destino_id'],
      cantidad: ApiService.aDouble(map['monto_origen']),
      cantidadDestino: ApiService.aDouble(map['monto_destino'] ?? map['monto_origen']),
      descripcion: map['descripcion'],
      fechaTransferencia: DateTime.parse(map['fecha']).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': idTransferencia,
      'uid': uid,
      'cuenta_origen_id': idCuentaOrigen,
      'cuenta_destino_id': idCuentaDestino,
      'monto_origen': cantidad,
      'monto_destino': cantidadDestino,
      'descripcion': descripcion,
      'fecha': fechaTransferencia.toUtc().toIso8601String(),
    };
  }

  static List<TransferenciaModel> _lista(dynamic data) =>
      (data as List<dynamic>).map((t) => TransferenciaModel.fromMap(t)).toList();

  // Todas las transferencias del usuario
  static Future<List<TransferenciaModel>> getTransferencias() async {
    return _lista(await ApiService.get('/transferencias'));
  }

  static Future<List<TransferenciaModel>> cargarTransferenciasPorCuentaOrigen(String idCuentaOrigen) async {
    return _lista(await ApiService.get('/transferencias', query: {'cuenta_origen_id': idCuentaOrigen}));
  }

  // Periodo: 'Día' | 'Semana' | 'Mes' | 'Año'
  static Future<List<TransferenciaModel>> cargarTransferenciasPorFecha(String periodo,
      {int? month, int? year}) async {
    const validos = ['Día', 'Semana', 'Mes', 'Año'];
    if (!validos.contains(periodo)) throw ArgumentError('Periodo no válido');
    return _lista(await ApiService.get('/transferencias', query: {
      'periodo': periodo,
      'mes': month,
      'anio': year,
    }));
  }
}

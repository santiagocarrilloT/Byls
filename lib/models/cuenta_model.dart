import 'package:byls_app/services/api_service.dart';

class CuentaModel {
  final String idCuenta; // ObjectId de MongoDB en texto
  final String uid;
  final String nombreCuenta;
  final double saldo;
  final String? tipoMoneda;
  final String? icono;
  final String? tipoCuenta;

  CuentaModel({
    required this.idCuenta,
    required this.uid,
    required this.nombreCuenta,
    required this.saldo,
    this.tipoMoneda,
    this.icono,
    this.tipoCuenta,
  });

  // Método para obtener el saldo de una cuenta específica
  static Future<double> getSaldoCuenta(String idCuenta) async {
    final response = await ApiService.get('/cuentas/$idCuenta/saldo');
    return ApiService.aDouble(response['saldo']);
  }

  // Método para convertir un mapa (documento de la colección "cuentas") en CuentaModel
  factory CuentaModel.fromMap(Map<String, dynamic> map) {
    return CuentaModel(
      idCuenta: map['_id'],
      uid: map['uid'] ?? '',
      nombreCuenta: map['nombre_cuenta'] ?? '',
      saldo: ApiService.aDouble(map['saldo']),
      tipoMoneda: map['moneda'],
      icono: map['icono_cuenta'],
      tipoCuenta: map['tipo_cuenta'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': idCuenta,
      'uid': uid,
      'nombre_cuenta': nombreCuenta,
      'saldo': saldo,
      'moneda': tipoMoneda,
      'icono_cuenta': icono,
      'tipo_cuenta': tipoCuenta,
    };
  }

  // Cuentas del usuario. El backend filtra por el usuario del token, el
  // parámetro se conserva para no romper las llamadas existentes.
  static Future<List<CuentaModel>> getCuentas([String? userId]) async {
    final List<dynamic> cuentas = await ApiService.get('/cuentas');
    return cuentas.map((item) => CuentaModel.fromMap(item)).toList();
  }

  static Future<Map<String, String>> cuentasPorNombre() async {
    final cuentas = await getCuentas();
    return {for (final c in cuentas) c.idCuenta: c.nombreCuenta};
  }

  // Patrimonio total por día (antes tabla "totalcuentasdiario", ahora aggregation en MongoDB)
  static Future<List<Map<String, dynamic>>> saldoTotalUsuario([String? idUsuario]) async {
    final List<dynamic> totalCuentas = await ApiService.get('/reportes/saldo-diario');
    return totalCuentas
        .map((item) => {
              'fecha': DateTime.parse(item['fecha']).toLocal(),
              'total': item['total'],
            })
        .toList();
  }
}

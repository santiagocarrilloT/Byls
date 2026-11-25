import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:byls_app/services/sesion.dart';

/// Cliente HTTP para la API de Byls (backend Node + MongoDB).
///
/// La app ya NO habla directo con la base de datos: todas las consultas
/// (get, post, put, delete) pasan por el backend en `backend/`.
///
/// URL del backend:
///   - Por defecto: http://10.0.2.2:3000/api en el emulador de Android
///     (10.0.2.2 es el "localhost" del PC visto desde el emulador) y
///     http://localhost:3000/api en web, Windows, macOS, Linux e iOS simulador.
///   - Para un celular físico o el servidor desplegado:
///       flutter run --dart-define=API_URL=http://192.168.1.50:3000/api
class ApiService {
  static const String _urlDefinida = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const Duration _timeout = Duration(seconds: 20);

  static Map<String, String> _headers() {
    // Token JWT que entrega el backend al iniciar sesión (usuarios en MongoDB).
    final token = Sesion.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Uri _uri(String ruta, [Map<String, dynamic>? query]) {
    final limpio = <String, String>{};
    query?.forEach((k, v) {
      if (v != null) limpio[k] = v.toString();
    });
    return Uri.parse('$baseUrl$ruta').replace(queryParameters: limpio.isEmpty ? null : limpio);
  }

  static dynamic _procesar(http.Response r) {
    final cuerpo = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 200 && r.statusCode < 300) return cuerpo;
    final mensaje = cuerpo is Map && cuerpo['error'] != null ? cuerpo['error'] : 'Error ${r.statusCode}';
    throw ApiException(r.statusCode, mensaje.toString());
  }

  static Future<dynamic> get(String ruta, {Map<String, dynamic>? query}) async {
    final r = await http.get(_uri(ruta, query), headers: _headers()).timeout(_timeout);
    return _procesar(r);
  }

  static Future<dynamic> post(String ruta, [Map<String, dynamic>? cuerpo]) async {
    final r = await http.post(_uri(ruta), headers: _headers(), body: jsonEncode(cuerpo ?? {})).timeout(_timeout);
    return _procesar(r);
  }

  static Future<dynamic> put(String ruta, Map<String, dynamic> cuerpo) async {
    final r = await http.put(_uri(ruta), headers: _headers(), body: jsonEncode(cuerpo)).timeout(_timeout);
    return _procesar(r);
  }

  static Future<dynamic> delete(String ruta, {Map<String, dynamic>? query}) async {
    final r = await http.delete(_uri(ruta, query), headers: _headers()).timeout(_timeout);
    return _procesar(r);
  }

  /// "gasto" -> "Gasto": la UI compara con 'Gasto' / 'Ingreso'.
  static String capitalizar(String? texto) {
    if (texto == null || texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  static double aDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
}

class ApiException implements Exception {
  final int status;
  final String mensaje;
  ApiException(this.status, this.mensaje);

  @override
  String toString() => mensaje;
}

import 'package:shared_preferences/shared_preferences.dart';

/// Usuario que inició sesión (antes venía de Supabase Auth).
class UsuarioSesion {
  final String id; // ObjectId del documento en la colección "usuarios"
  final String email;
  const UsuarioSesion({required this.id, required this.email});
}

/// Guarda el token JWT del backend y el usuario actual, en memoria y en el
/// dispositivo (SharedPreferences) para que la sesión siga al cerrar la app.
class Sesion {
  static const _kToken = 'byls_token';
  static const _kId = 'byls_usuario_id';
  static const _kEmail = 'byls_usuario_email';

  static String? token;
  static UsuarioSesion? usuario;

  static bool get activa => token != null && usuario != null;

  /// Lee la sesión guardada. Llamarlo al iniciar la app (y en tareas en segundo plano).
  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_kToken);
    final id = prefs.getString(_kId);
    final email = prefs.getString(_kEmail);
    usuario = (id != null && email != null) ? UsuarioSesion(id: id, email: email) : null;
  }

  static Future<void> guardar(String nuevoToken, Map<String, dynamic> datosUsuario) async {
    token = nuevoToken;
    usuario = UsuarioSesion(id: datosUsuario['id'], email: datosUsuario['email']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, nuevoToken);
    await prefs.setString(_kId, usuario!.id);
    await prefs.setString(_kEmail, usuario!.email);
  }

  static Future<void> cerrar() async {
    token = null;
    usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kId);
    await prefs.remove(_kEmail);
  }
}

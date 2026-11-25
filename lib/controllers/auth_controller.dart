import 'package:byls_app/services/api_service.dart';
import 'package:byls_app/services/sesion.dart';

// Controladores para la sesión del usuario.
// Antes usaba Supabase Auth; ahora los usuarios viven en MongoDB (colección
// "usuarios") y el backend entrega un token JWT.
class AuthController {
  Future<void> signInCt(String email, String password) async {
    final r = await ApiService.post('/auth/login', {'email': email.trim(), 'password': password});
    await Sesion.guardar(r['token'], r['usuario']);
  }

  // Crea el usuario y deja la sesión iniciada (ya no hay correo de confirmación).
  Future<void> signUpCt(String email, String password) async {
    final r = await ApiService.post('/auth/registro', {'email': email.trim(), 'password': password});
    await Sesion.guardar(r['token'], r['usuario']);
  }

  Future<void> signOutCt() async {
    await Sesion.cerrar();
  }

  // Genera un código de recuperación de 6 dígitos. Como no hay servicio de
  // correo, el código aparece en la consola del backend (terminal de npm run dev).
  Future<void> resetPasswordCt(String email) async {
    await ApiService.post('/auth/recuperar', {'email': email.trim()});
  }

  // Verifica el código y deja la sesión iniciada para poder cambiar la contraseña.
  Future<bool> verifyOTPandChangePassword(String otp, String email) async {
    try {
      final r = await ApiService.post('/auth/verificar-codigo', {'email': email.trim(), 'codigo': otp.trim()});
      await Sesion.guardar(r['token'], r['usuario']);
      return true;
    } on ApiException catch (e) {
      if (e.status == 400) return false;
      rethrow;
    }
  }

  Future<void> updatePasswordCt(String newPassword) async {
    if (!Sesion.activa) throw Exception('No hay una sesión activa');
    await ApiService.post('/auth/cambiar-password', {'nueva': newPassword});
  }

  UsuarioSesion? get currentUser => Sesion.usuario;

  // Revisa si hay una sesión guardada y si el backend la sigue aceptando.
  Future<bool> verifySesion() async {
    await Sesion.cargar();
    if (!Sesion.activa) return false;
    try {
      await ApiService.get('/auth/yo');
      return true;
    } on ApiException catch (e) {
      if (e.status == 401) {
        await Sesion.cerrar();
        return false;
      }
      return true;
    } catch (_) {
      // Backend apagado o sin red: se conserva la sesión guardada.
      return true;
    }
  }
}

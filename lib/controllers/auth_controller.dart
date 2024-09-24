import 'package:supabase_flutter/supabase_flutter.dart';

//Controladores para la sesión del usuario
class AuthController {
  final _client = Supabase.instance.client;

  Future<void> signInCt(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signUpCt(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signOutCt() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> resetPasswordCt(String email) async {
    try {
      final response = await _client.auth.resetPasswordForEmail(
        email,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> verifyOTPandChangePassword(String otp, String email) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.user?.email == email) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  User? get currentUser => _client.auth.currentUser;

  // Función para insertar una transacción
  Future<void> insertarTransaccion({
    required String descripcion,
    required int nombre_categoria,
    required double montoTransaccion,
    required String tipoTransaccion, // 'Ingreso' o 'Gasto'
    required DateTime fechaTransaccion,
  }) async {
    final response = await _client
        .from('transacciones')
        .insert({
          'descripcion': descripcion,
          'monto_transaccion': montoTransaccion,
          'tipo_transaccion': tipoTransaccion,
          'fecha_transaccion': fechaTransaccion.toIso8601String(),
          'nombre_categoria': nombre_categoria,
          // 'id_cuenta': idCuenta, // Añádelo cuando tengas el id_cuenta
        });

    if (response.error != null) {
      throw Exception('Error al insertar la transacción: ${response.error!.message}');
    }
  }
}

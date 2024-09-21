import 'package:supabase/supabase.dart';
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
}

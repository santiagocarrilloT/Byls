import 'package:supabase_flutter/supabase_flutter.dart';

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
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(e);
    }
  }

  User? get currentUser => _client.auth.currentUser;
}

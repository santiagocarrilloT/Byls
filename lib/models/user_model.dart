import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;

  UserModel({required this.id, required this.email});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
    };
  }

  static Future<UserModel?> getUsuarioActual() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      //Objeto Usuario
      final usuario = UserModel(
        id: user.id, // ID del usuario autenticado
        email: user.email!, // Email del usuario
      );
      return usuario;
    } else {
      print('No hay usuario autenticado');
      return null;
    }
  }
}

class CurrentUser {
  Future<UserModel?> getCurrentUser() {
    return UserModel.getUsuarioActual();
  }
}

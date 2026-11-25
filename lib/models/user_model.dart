import 'package:byls_app/services/sesion.dart';

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
    final user = Sesion.usuario;
    if (user == null) return null;
    return UserModel(id: user.id, email: user.email);
  }
}

class CurrentUser {
  Future<UserModel?> getCurrentUser() {
    return UserModel.getUsuarioActual();
  }
}

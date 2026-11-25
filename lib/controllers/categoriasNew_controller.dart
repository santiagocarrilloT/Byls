import 'package:byls_app/services/api_service.dart';
import 'package:byls_app/services/sesion.dart';

class AuthController {
  // Inserta una nueva categoría del usuario en la colección "categorias"
  Future<void> insertarCategoria(String nombre, String color, String tipo, String icono) async {
    final user = Sesion.usuario;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    try {
      await ApiService.post('/categorias', {
        'nombre_categoria': nombre,
        'color_categoria': color,
        'tipo_categoria': tipo.toLowerCase(),
        'icono_categoria': icono,
      });
    } catch (e) {
      throw Exception('Error al guardar la categoría: $e');
    }
  }
}

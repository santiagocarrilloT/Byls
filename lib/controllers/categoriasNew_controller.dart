import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  // Función para insertar una nueva categoría en Supabase
  Future<void> insertarCategoria(String nombre, String color, String tipo, String icono) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    try {
      // Inserción en la tabla 'categoriasusuario'
      final response = await Supabase.instance.client
          .from('categoriasusuario')
          .insert({
            'nombre_categoria': nombre,
            'color_categoria': color,
            'tipo_categoria': tipo,
            'icono_categoria': icono,
            'uid': user.id,
          })
          .select(); // Usamos select() para obtener la respuesta

      if (response.isNotEmpty) {
        // La inserción fue exitosa si la respuesta no está vacía
        print('Categoría guardada con éxito: $response');
      } else {
        // Si la respuesta está vacía, puede que algo haya fallado
        throw Exception("No se obtuvo una respuesta válida después de la inserción.");
      }
    } catch (e) {
      // Manejo de excepciones si ocurre algún error
      print('Error al guardar la categoría: $e');
      throw Exception('Error al guardar la categoría: $e');
    }
  }
}

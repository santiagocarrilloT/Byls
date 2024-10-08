import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriasusuarioModel {

  final String nombreCategoria;
  final String colorCategoria;
  final String tipoCategoria; 
  final String iconoCategoria; 

  CategoriasusuarioModel({
    required this.nombreCategoria,
    required this.colorCategoria,
    required this.tipoCategoria,
    required this.iconoCategoria,
  });

  // Crear una instancia de TransaccionModel desde un Map
  factory CategoriasusuarioModel.fromMap(Map<String, dynamic> map) {
    return CategoriasusuarioModel(
      nombreCategoria: map['nombre_categoria'],
      colorCategoria: map['color_categoria'],
      tipoCategoria: map['tipo_categoria'],
      iconoCategoria: map['icono_categoria'],
    );
  }

  // Convertir la instancia de TransaccionModel a Map
  Map<String, dynamic> toMap() {
    return {
      'nombre_categoria': nombreCategoria,
      'color_categoria': colorCategoria,
      'tipo_categoria': tipoCategoria,
      'icono_categoria': iconoCategoria,
    };
  }

  // Método para traer las transacciones filtradas por idCuenta
  static Future<List<CategoriasusuarioModel>> getCategoriasUsuario() async {

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final response = await Supabase.instance.client
          .from('categoriasusuario')
          .select()
          .eq('uid', user!.id);
           // Filtrando por id_cuenta
          final List<CategoriasusuarioModel> cuentasUsuario = [];
          for (final item in response) {
            cuentasUsuario.add(CategoriasusuarioModel.fromMap(item));
          }
          return cuentasUsuario;
          } catch (e) {
            print('Error al obtener las categorías: $e');
            throw e;
          }
  }
  /* Future<List<Map<String, dynamic>>> fetchCategorias() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    try {
      // Consulta a la tabla 'categoriasusuario'
      final response = await Supabase.instance.client
          .from('categoriasusuario')
          .select()
          .eq('uid', user.id);

      if (response.isNotEmpty) {
        // Si la respuesta contiene datos, los retornamos
        return List<Map<String, dynamic>>.from(response);
      } else {
        // Si no hay datos, retornamos una lista vacía
        return [];
      }
    } catch (e) {
      // Manejo de excepciones si ocurre algún error
      print('Error al obtener las categorías: $e');
      throw e;
    }
  } */
}
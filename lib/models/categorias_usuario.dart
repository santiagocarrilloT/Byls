import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriasusuarioModel {
  final int idCategoria;
  final String uid;
  final String nombreCategoria;
  final String colorCategoria;
  final String tipoCategoria;
  final String iconoCategoria;

  // Constructor privado para evitar la instanciación directa
  CategoriasusuarioModel._({
    required this.uid,
    required this.idCategoria,
    required this.nombreCategoria,
    required this.colorCategoria,
    required this.tipoCategoria,
    required this.iconoCategoria,
  });

  // Método para convertir un mapa en una instancia de CategoriasusuarioModel
  factory CategoriasusuarioModel.fromMap(Map<String, dynamic> map) {
    return CategoriasusuarioModel._(
      idCategoria: map['id_categoria'],  
      uid: map['uid'],
      nombreCategoria: map['nombre_categoria'],
      colorCategoria: map['color_categoria'],
      tipoCategoria: map['tipo_categoria'],
      iconoCategoria: map['icono_categoria'],
    );
  }

  // Método para obtener las categorías de un usuario por su UID
  static Future<List<CategoriasusuarioModel>> getCategorias(String userId) async {
    final categorias = await Supabase.instance.client
        .from('categoriasusuario')
        .select()
        .eq('uid', userId) as List<dynamic>?;

    // Convertimos los datos a una lista de CategoriasusuarioModel
    final List<CategoriasusuarioModel> categoriasUsuario = [];
    if (categorias != null) {
      for (final item in categorias) {
        // Crea la instancia usando el fromMap
        categoriasUsuario.add(CategoriasusuarioModel.fromMap(item));
      }
    }
    return categoriasUsuario;
  }
}

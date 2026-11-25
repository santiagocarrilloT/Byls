import 'package:byls_app/services/api_service.dart';

class CategoriasusuarioModel {
  final String idCategoria; // ObjectId de MongoDB en texto
  final String uid;
  final String nombreCategoria;
  final String colorCategoria; // formato 0xFFRRGGBB
  final String tipoCategoria; // 'Gasto' | 'Ingreso'
  final String iconoCategoria;
  final bool esSistema;

  CategoriasusuarioModel._({
    required this.uid,
    required this.idCategoria,
    required this.nombreCategoria,
    required this.colorCategoria,
    required this.tipoCategoria,
    required this.iconoCategoria,
    required this.esSistema,
  });

  // Documento de la colección "categorias" -> CategoriasusuarioModel
  factory CategoriasusuarioModel.fromMap(Map<String, dynamic> map) {
    return CategoriasusuarioModel._(
      idCategoria: map['_id'],
      uid: map['uid'] ?? '',
      nombreCategoria: map['nombre_categoria'] ?? '',
      colorCategoria: map['color_categoria'] ?? '0xFF9E9E9E',
      tipoCategoria: ApiService.capitalizar(map['tipo_categoria']),
      iconoCategoria: map['icono_categoria'] ?? '',
      esSistema: map['es_sistema'] == true,
    );
  }

  // Categorías creadas por el usuario (las del sistema ya vienen fijas en
  // lib/models/categorias.dart, por eso se piden con solo_usuario=true).
  static Future<List<CategoriasusuarioModel>> getCategorias([String? userId]) async {
    final List<dynamic> categorias = await ApiService.get('/categorias', query: {'solo_usuario': 'true'});
    return categorias.map((item) => CategoriasusuarioModel.fromMap(item)).toList();
  }

  // nombre -> color
  static Future<Map<String, String>> getCategoriasNombre([String? userId]) async {
    final categorias = await getCategorias();
    return {for (var cat in categorias) cat.nombreCategoria: cat.colorCategoria};
  }

  // nombre -> icono
  static Future<Map<String, String>> getCategoriasIcono([String? userId]) async {
    final categorias = await getCategorias();
    return {for (var cat in categorias) cat.nombreCategoria: cat.iconoCategoria};
  }
}

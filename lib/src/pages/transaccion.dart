import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/models/categorias_usuario.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/src/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/src/pages/crearCategoria.dart';
import 'package:byls_app/models/categorias.dart'; // Importamos las categorías predeterminadas

class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  bool isGastosSelected = true; // Alternar entre Gastos e Ingresos
  String? selectedCategory; // Categoría seleccionada
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  List<CategoriasusuarioModel> categoriasGastoUsuario = [];
  List<CategoriasusuarioModel> categoriasIngresoUsuario = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasUsuario();
  }

  // Método para cargar las categorías del usuario
  Future<void> _cargarCategoriasUsuario() async {
    try {
      final authService = Provider.of<AuthController>(context, listen: false);
      final uid = authService.currentUser?.id;

      if (uid != null) {
        final categorias = await CategoriasusuarioModel.getCategorias(uid);

        setState(() {
          categoriasGastoUsuario = categorias
              .where((categoria) => categoria.tipoCategoria == 'Gasto')
              .toList();
          categoriasIngresoUsuario = categorias
              .where((categoria) => categoria.tipoCategoria == 'Ingreso')
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('El UID del usuario es nulo.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las categorías: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para convertir CategoriasusuarioModel a Categoria
  Categoria _convertirCategoriaUsuarioACategoria(
      CategoriasusuarioModel categoriaUsuario) {
    return Categoria(
      id: categoriaUsuario.idCategoria, // Asume que id es un string y lo convierte a int
      nombre: categoriaUsuario.nombreCategoria,
      icono: _getIconByName(categoriaUsuario.iconoCategoria),
      color: Color(int.parse(categoriaUsuario.colorCategoria)),
    );
  }

  //Función para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Crea una instancia de AuthController
  final AuthController authController = AuthController();

  Future<void> _guardarTransaccion() async {
    if (selectedCategory == null ||
        _cantidadController.text.isEmpty ||
        _descripcionController.text.isEmpty) {
      // Mostrar un mensaje de error si falta algún campo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    try {
      final double cantidad = double.parse(_cantidadController.text);
      final tipoTransaccion = isGastosSelected ? 'Gasto' : 'Ingreso';

      // Insertar la transacción en la base de datos usando AuthController
      await authController.insertarTransaccion(
        _descripcionController.text,
        selectedCategory!,
        cantidad,
        tipoTransaccion,
        selectedDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción guardada con éxito')),
      );
      context.go("/app_entry");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la transacción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convertir las categorías de usuario a objetos de tipo Categoria
    List<Categoria> categoriasUsuarioConvertidas = isGastosSelected
        ? categoriasGastoUsuario
            .map((categoria) => _convertirCategoriaUsuarioACategoria(categoria))
            .toList()
        : categoriasIngresoUsuario
            .map((categoria) => _convertirCategoriaUsuarioACategoria(categoria))
            .toList();

    // Obtener las categorías predeterminadas
    List<Categoria> categoriasPredeterminadas = isGastosSelected
        ? categoriasGasto
        : categoriasIngreso;

    // Combinar ambas listas
    final categories = [...categoriasUsuarioConvertidas, ...categoriasPredeterminadas];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/app_entry");
          },
        ),
        title: const Text("Transacción"),
      ),
      backgroundColor: const Color(0xFF006064),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isGastosSelected = true;
                              selectedCategory = null;
                            });
                          },
                          child: Text(
                            'Gastos',
                            style: TextStyle(
                              color: isGastosSelected
                                  ? const Color(0xFF00BFA5)
                                  : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isGastosSelected = false;
                              selectedCategory = null;
                            });
                          },
                          child: Text(
                            'Ingreso',
                            style: TextStyle(
                              color: !isGastosSelected
                                  ? const Color(0xFF00BFA5)
                                  : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 350,
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1,
                        ),
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == categories.length) {
                            return GestureDetector(
                              onTap: () {
                                context.go("/crearCategoria");
                              },
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Crear',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final category = categories[index];
                          final isSelected = category.nombre == selectedCategory;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category.nombre;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: isSelected
                                      ? const Color.fromARGB(255, 0, 0, 0)
                                      : category.color,
                                  child: Icon(
                                    category.icono,
                                    color: isSelected ? Colors.white : Colors.black,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.nombre,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Seleccionar fecha'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00BFA5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00BFA5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _guardarTransaccion,
                        child: const Text('Guardar Transacción'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

IconData _getIconByName(String iconName) {
  switch (iconName) {
    // Iconos para categorías de gastos
    case 'house':
      return Icons.home;
    case 'school':
      return Icons.school;
    case 'fastfood':
      return Icons.fastfood;
    case 'local_gas_station':
      return Icons.local_gas_station;
    case 'phone_android':
      return Icons.phone_android;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'car_rental':
      return Icons.car_rental;
    case 'hotel':
      return Icons.hotel;
    case 'health_and_safety':
      return Icons.health_and_safety;

    // Iconos para categorías de ingresos
    case 'attach_money':
      return Icons.attach_money;
    case 'trending_up':
      return Icons.trending_up;
    case 'monetization_on':
      return Icons.monetization_on;
    case 'account_balance_wallet':
      return Icons.account_balance_wallet;
    case 'business':
      return Icons.business;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'store':
      return Icons.store;
    case 'pie_chart':
      return Icons.pie_chart;
    // Ícono por defecto si no coincide con ninguna categoría
    default:
      return Icons.help; 
  }
}



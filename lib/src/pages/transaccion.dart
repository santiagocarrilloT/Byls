import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/categorias_usuario.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/models/categorias.dart'; // Importamos las categorías predeterminadas

class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  List<CuentaModel> cuentas = [];
  bool isGastosSelected = true; // Alternar entre Gastos e Ingresos
  String? selectedCategory; // Categoría seleccionada
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  List<CategoriasusuarioModel> categoriasGastoUsuario = [];
  List<CategoriasusuarioModel> categoriasIngresoUsuario = [];

  bool isLoading = true;

  int? selectedCuentaId;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasUsuario();
    fetchCuentas();
  }

  CuentaController cuentaController = CuentaController();
  IngresosController ingresosController = IngresosController();

  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        selectedCuentaId = cuentas[0].idCuenta;
      }
    });
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
      id: categoriaUsuario
          .idCategoria, // Asume que id es un string y lo convierte a int
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
    List<Categoria> categoriasPredeterminadas =
        isGastosSelected ? categoriasGasto : categoriasIngreso;

    // Combinar ambas listas
    final categories = [
      ...categoriasUsuarioConvertidas,
      ...categoriasPredeterminadas
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/app_entry");
          },
        ),
        title: const Text("Transacción"),
        actions: [
          //Notificación de transacción
          IconButton(
            icon: const Icon(Icons.notification_add,
                color: Color.fromARGB(255, 63, 158, 81)),
            onPressed: () async {
              if (selectedCategory != null &&
                  _descripcionController.text.isNotEmpty &&
                  _cantidadController.text.isNotEmpty) {
                final Map<String, dynamic> extra = {
                  'idCuenta': selectedCuentaId.toString(),
                  'descripcion': _descripcionController.text,
                  'categoria': selectedCategory,
                  'cantidad': double.parse(_cantidadController.text),
                  'tipoTransaccion': isGastosSelected ? 'Gasto' : 'Ingreso',
                  'fecha': selectedDate,
                };

                context.go('/configurarNotificaciones', extra: extra);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, complete todos los campos'),
                    backgroundColor: Colors.yellow,
                  ),
                );
              }
            },
          ),
        ],
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
                    const SizedBox(height: 7),

                    // Campo de texto para la cantidad
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
                    const SizedBox(height: 15),

                    // Selector de cuenta
                    DropdownButtonFormField(
                      value: selectedCuentaId,
                      style: const TextStyle(color: Color(0xFF00BFA5)),
                      dropdownColor: const Color(0xFF00BFA5),
                      items: cuentas
                          .map((cuenta) => DropdownMenuItem(
                                value: cuenta.idCuenta,
                                child: Text(
                                  cuenta.nombreCuenta,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedCuentaId = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Cuenta',
                        labelStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF00BFA5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Color(0xFF00BFA5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Color(0xFF00BFA5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

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

                    // Selector de categorías
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
                          final isSelected =
                              category.nombre == selectedCategory;

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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
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

                    const SizedBox(height: 10),

                    // Selector de fecha
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

                    const SizedBox(height: 10),

                    // Campo para la descripción
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _descripcionController,
                      maxLines: 2,
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
                        onPressed: () async {
                          // Cuenta seleccionada
                          String idCuentaSelec = (cuentas
                                  .firstWhere((element) =>
                                      element.idCuenta == selectedCuentaId)
                                  .idCuenta)
                              .toString();

                          // Saldo de la cuenta seleccionada
                          double saldo = (cuentas
                                  .firstWhere((element) =>
                                      element.idCuenta == selectedCuentaId)
                                  .saldo)
                              .toDouble();

                          try {
                            if (_cantidadController.text != '' ||
                                _descripcionController.text != '' ||
                                selectedCategory != null) {
                              //Insertar gasto o ingreso
                              await ingresosController.insertarTransaccion(
                                  idCuentaSelec,
                                  _descripcionController.text,
                                  selectedCategory!,
                                  double.parse(_cantidadController.text),
                                  isGastosSelected ? 'Gasto' : 'Ingreso',
                                  selectedDate);

                              //Actualizar saldo de la cuenta
                              cuentaController.actualizarSaldo(
                                  saldo,
                                  idCuentaSelec,
                                  double.parse(_cantidadController.text),
                                  isGastosSelected ? false : true);

                              //Mostrar mensaje de gasto o ingreso guardado
                              ScaffoldMessenger.of(context).showSnackBar(
                                isGastosSelected
                                    ? const SnackBar(
                                        content: Text('Gasto guardado'),
                                        backgroundColor: Colors.green,
                                      )
                                    : const SnackBar(
                                        content: Text('Ingreso guardado'),
                                        backgroundColor: Colors.green,
                                      ),
                              );

                              //Redirigir a la pantalla de ingresos
                              context.go("/app_entry");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Por favor, complete todos los campos'),
                                  backgroundColor: Colors.yellow,
                                ),
                              );
                              return;
                            }
                          } catch (e) {
                            // Mostrar mensaje de error al guardar gasto o ingreso
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isGastosSelected
                                    ? 'Error al guardar gasto'
                                    : 'Error al guardar ingreso'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          //Cuenta que fue seleccionada
                        },
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

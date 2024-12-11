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
          color: Colors.white,
        ),
        //poner color al text del appbar
        title: const Text("Transacción", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF044454),
        actions: [
          //Notificación de transacción
          IconButton(
            icon: const Icon(Icons.notification_add, color: Color(0xFF00BFA5)),
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
      backgroundColor: const Color(0xFF04242C),
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
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.attach_money,
                            color: Color(0xFF00BFA5)),
                        // Borde cuando el campo está enfocado
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF00BFA5), width: 2.0),
                        ),
                        // Borde cuando el campo está habilitado pero no enfocado
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF044454), width: 2.0),
                        ),
                        // Sin borde adicional para el estado normal
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF044454), width: 2.0),
                        ),
                        filled: true, // Fondo para el campo
                        fillColor: const Color(0xFF044454), // Color del fondo
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Selector de cuenta
                    DropdownButtonFormField(
                      value: selectedCuentaId,
                      style: const TextStyle(color: Color(0xFF00BFA5)),
                      dropdownColor: const Color(0xFF044454),
                      items: cuentas
                          .map((cuenta) => DropdownMenuItem(
                                value: cuenta.idCuenta,
                                child: Text(
                                  cuenta.nombreCuenta,
                                  style: const TextStyle(color: Colors.white),
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
                              const BorderSide(color: Color(0xFF044454)),
                        ),
                        filled: true, // Habilita el fondo del campo
                        fillColor: const Color(0xFF044454), // Fondo del campo
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
                                  : Colors.white,
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
                                  : Colors.white,
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
                                      color: Colors.white,
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
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.nombre,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF00BFA5)),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(selectedDate),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF044454),
                          ),
                          child: const Text('Seleccionar fecha'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Campo para la descripción
                    TextField(
                      style: const TextStyle(
                          color: Colors.white), // Color del texto ingresado
                      controller: _descripcionController,
                      maxLines: 2, // Permitir hasta 2 líneas
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: const TextStyle(
                            color: Colors.white), // Estilo de la etiqueta
                        prefixIcon: const Icon(Icons.edit,
                            color: Color(0xFF00BFA5)), // Ícono al inicio
                        filled: true, // Activar fondo personalizado
                        fillColor:
                            const Color(0xFF044454), // Color de fondo del campo
                        // Borde al enfocar
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF00BFA5), width: 2.0),
                        ),
                        // Borde cuando no está enfocado
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF044454), width: 2.0),
                        ),
                        // Borde por defecto
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF044454), width: 2.0),
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
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF044454),
                        ),
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
    case 'kitchen':
      return Icons.kitchen;
    case 'bed':
      return Icons.bed;
    case 'weekend':
      return Icons.weekend;
    case 'bathtub':
      return Icons.bathtub;
    case 'lightbulb':
      return Icons.lightbulb;
    case 'directions_car':
      return Icons.directions_car;
    case 'motorcycle':
      return Icons.motorcycle;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'directions_bike':
      return Icons.directions_bike;
    case 'local_shipping':
      return Icons.local_shipping;
    case 'airplanemode_active':
      return Icons.airplanemode_active;
    case 'train':
      return Icons.train;
    case 'directions_subway':
      return Icons.directions_subway;
    case 'local_pizza':
      return Icons.local_pizza;
    case 'local_cafe':
      return Icons.local_cafe;
    case 'local_dining':
      return Icons.local_dining;
    case 'movie':
      return Icons.movie;
    case 'music_note':
      return Icons.music_note;
    case 'tv':
      return Icons.tv;
    case 'book':
      return Icons.book;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'pets':
      return Icons.pets;

    // Iconos para categorías de ingresos
    case 'attach_money':
      return Icons.attach_money;
    case 'trending_up':
      return Icons.trending_up;
    case 'account_balance_wallet':
      return Icons.account_balance_wallet;
    case 'business':
      return Icons.business;
    case 'school':
      return Icons.school;
    case 'science':
      return Icons.science;
    case 'work':
      return Icons.work;
    case 'engineering':
      return Icons.engineering;
    case 'explore':
      return Icons.explore;
    case 'beach_access':
      return Icons.beach_access;
    case 'phone_android':
      return Icons.phone_android;
    case 'computer':
      return Icons.computer;
    case 'devices':
      return Icons.devices;
    // Ícono por defecto si no coincide con ninguna categoría
    default:
      return Icons.help;
  }
}

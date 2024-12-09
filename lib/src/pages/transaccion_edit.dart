import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/categorias.dart';
import 'package:byls_app/models/categorias_usuario.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TransaccionEdit extends StatefulWidget {
  final IncomeModel transaccion;

  const TransaccionEdit({super.key, required this.transaccion});

  @override
  State<TransaccionEdit> createState() =>
      _TransaccionEditState(transaccion: transaccion);
}

class _TransaccionEditState extends State<TransaccionEdit> {
  List<CuentaModel> cuentas = [];
  CuentaController cuentaController = CuentaController();
  final AuthController authController = AuthController();
  IngresosController ingresosController = IngresosController();
  final IncomeModel transaccion;
  _TransaccionEditState({required this.transaccion});
  List<IncomeModel> futureTransaccion = [];

  bool isGastosSelected = true;
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();
  int? selectedCuentaId;

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  List<CategoriasusuarioModel> categoriasGastoUsuario = [];
  List<CategoriasusuarioModel> categoriasIngresoUsuario = [];

  bool isLoading = true;

  // Cargar transacciones del usuario
  Future<void> fetchTransacciones() async {
    //final authService = Provider.of<AuthController>(context, listen: false);
    //final userId = authService.currentUser?.id;

    if (selectedCuentaId != null) {
      await IncomeModel.getTransacciones(selectedCuentaId!).then((value) {
        setState(() {
          futureTransaccion = value;
        });
      });
    }
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

//Función para obtener el saldo total de las cuentas
  double getSaldoTotal(double suma, int index) {
    if (index == futureTransaccion.length) {
      return suma;
    } else {
      if (futureTransaccion[index].tipoTransaccion == 'Ingreso') {
        return getSaldoTotal(
            suma + futureTransaccion[index].montoTransaccion, index + 1);
      } else {
        return getSaldoTotal(
            suma - futureTransaccion[index].montoTransaccion, index + 1);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    selectedCategory = transaccion.tipoTransaccion;
    selectedDate = transaccion.fechaTransaccion;
    _cantidadController.text = transaccion.montoTransaccion.toString();
    _descripcionController.text = transaccion.descripcion!;
    isGastosSelected = transaccion.tipoTransaccion == 'Gasto' ? true : false;
    _cargarCategoriasUsuario();
    fetchTransacciones();
    fetchCuentas();

    selectedCategory = transaccion.nombreCategoria;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        selectedCuentaId = transaccion.idCuenta;
      }
    });
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
            context.go("/app_entry", extra: 1);
          },
        color: Colors.white,
        ),
        title: const Text("Editar Transacción", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF044454),
        actions: [
          //Notificación de transacción
          IconButton(
            icon: const Icon(Icons.notification_add,
                color: Color(0xFF00BFA5)),
            onPressed: () async {
              context.go('/configurarNotificaciones');
            },
          ),

          //Eliminar transacción
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              try {
                if (transaccion.tipoTransaccion == 'Ingreso') {
                  // Saldo de la cuenta seleccionada
                  double saldo = (cuentas
                          .firstWhere(
                              (element) => element.idCuenta == selectedCuentaId)
                          .saldo)
                      .toDouble();
                  //Actualizar saldo de la cuenta
                  cuentaController.actualizarSaldo(
                      saldo,
                      transaccion.idCuenta.toString(),
                      transaccion.montoTransaccion,
                      false);
                }

                await ingresosController
                    .deleteIngreso(transaccion.idTransaccion.toString());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transacción eliminada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/app_entry');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar transacción'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF04242C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 7),

              // Campo para ingresar la cantidad
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
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF00BFA5)),
                        // Borde cuando el campo está enfocado
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2.0),
                        ),
                        // Borde cuando el campo está habilitado pero no enfocado
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF044454), width: 2.0),
                        ),
                        // Sin borde adicional para el estado normal
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF044454), width: 2.0),
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

              // Selector de Gastos e Ingreso
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

              // Categorías
              SizedBox(
                height: 350,
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    final isSelected = selectedCategory == category.nombre;

                    return GestureDetector(
                      //Seleccionar una categoría predeterminada

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
                              color: Colors.white
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
                  const Icon(Icons.calendar_today, color: Color(0xFF00BFA5)),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color(0xFF044454),
                    ),
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
                decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: const TextStyle(color: Colors.white), // Estilo de la etiqueta
                        prefixIcon: const Icon(Icons.edit, color: Color(0xFF00BFA5)), // Ícono al inicio
                        filled: true, // Activar fondo personalizado
                        fillColor: const Color(0xFF044454), // Color de fondo del campo
                        // Borde al enfocar
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2.0),
                        ),
                        // Borde cuando no está enfocado
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF044454), width: 2.0),
                        ),
                        // Borde por defecto
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF044454), width: 2.0),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // Botón para guardar transacción
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF044454),
                  ),
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

                    double saldoCuentaAnterior = (cuentas
                            .firstWhere((element) =>
                                element.idCuenta == transaccion.idCuenta)
                            .saldo)
                        .toDouble();

                    try {
                      //Actualizar transacción
                      await ingresosController.updateIngreso(
                        idCuentaSelec,
                        transaccion.idTransaccion.toString(),
                        _descripcionController.text,
                        double.parse(_cantidadController.text),
                        isGastosSelected ? 'Gasto' : 'Ingreso',
                        selectedDate,
                        selectedCategory!,
                      );

                      //Actualizar saldo de las cuenta
                      if (transaccion.idCuenta != selectedCuentaId) {
                        cuentaController.actualizarSaldo(
                            saldo,
                            idCuentaSelec,
                            double.parse(_cantidadController.text),
                            isGastosSelected ? false : true);

                        if (transaccion.tipoTransaccion == 'Ingreso') {
                          //Disminuir saldo de la cuenta anterior
                          cuentaController.actualizarSaldo(
                              saldoCuentaAnterior,
                              transaccion.idCuenta.toString(),
                              transaccion.montoTransaccion,
                              false);
                        } else {
                          //Aumentar saldo de la cuenta anterior
                          cuentaController.actualizarSaldo(
                              saldoCuentaAnterior,
                              transaccion.idCuenta.toString(),
                              transaccion.montoTransaccion,
                              true);
                        }
                      } else {
                        if (transaccion.montoTransaccion !=
                            double.parse(_cantidadController.text)) {
                          //Actualizar saldo de la cuenta en caso de que tengo el mismo tipo de transacción
                          if (transaccion.tipoTransaccion == 'Ingreso' &&
                              !isGastosSelected) {
                            cuentaController.actualizarSaldoMonto(
                                saldoCuentaAnterior,
                                transaccion.idCuenta.toString(),
                                transaccion.montoTransaccion,
                                double.parse(_cantidadController.text),
                                false);
                          } else if (transaccion.tipoTransaccion == 'Gasto' &&
                              isGastosSelected) {
                            cuentaController.actualizarSaldoMonto(
                                saldoCuentaAnterior,
                                transaccion.idCuenta.toString(),
                                transaccion.montoTransaccion,
                                double.parse(_cantidadController.text),
                                true);
                          }
                          //Actualizar saldo de la cuenta en caso de que tenga diferente tipo de transacción
                          else if (transaccion.tipoTransaccion == 'Ingreso' &&
                              isGastosSelected) {
                            cuentaController.actualizarSaldoTipoTransaccion(
                                saldoCuentaAnterior,
                                transaccion.idCuenta.toString(),
                                transaccion.montoTransaccion,
                                double.parse(_cantidadController.text),
                                false);
                          } else if (transaccion.tipoTransaccion == 'Gasto' &&
                              !isGastosSelected) {
                            cuentaController.actualizarSaldoTipoTransaccion(
                                saldoCuentaAnterior,
                                transaccion.idCuenta.toString(),
                                transaccion.montoTransaccion,
                                double.parse(_cantidadController.text),
                                true);
                          }
                        } else {
                          //Actualizar saldo de la cuenta en caso de que tenga diferente tipo de transacción
                          if (transaccion.tipoTransaccion == 'Ingreso' &&
                              isGastosSelected) {
                            cuentaController.actualizarSaldoTipoTransaccion(
                                saldoCuentaAnterior,
                                transaccion.idCuenta.toString(),
                                transaccion.montoTransaccion,
                                double.parse(_cantidadController.text),
                                false);
                          } else if (transaccion.tipoTransaccion == 'Gasto' &&
                              !isGastosSelected) {
                            cuentaController.actualizarSaldoTipoTransaccion(
                                saldoCuentaAnterior,
                                transaccion.idCuenta.toString(),
                                transaccion.montoTransaccion,
                                double.parse(_cantidadController.text),
                                true);
                          }
                        }
                      }

                      //Mostrar mensaje de transacción actualizada
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transacción actualizada con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.go("/app_entry");
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transacción no actualizada'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Editar Transacción'),
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
    case 'living_room':
      return Icons.weekend;
    case 'bathroom':
      return Icons.bathtub;
    case 'electricity':
      return Icons.lightbulb;
    case 'car':
      return Icons.directions_car;
    case 'motorcycle':
      return Icons.motorcycle;
    case 'bus':
      return Icons.directions_bus;
    case 'bike':
      return Icons.directions_bike;
    case 'shipping':
      return Icons.local_shipping;
    case 'airplane':
      return Icons.airplanemode_active;
    case 'train':
      return Icons.train;
    case 'subway':
      return Icons.directions_subway;
    case 'pizza':
      return Icons.local_pizza;
    case 'cafe':
      return Icons.local_cafe;
    case 'restaurant':
      return Icons.local_dining;
    case 'movie':
      return Icons.movie;
    case 'music':
      return Icons.music_note;
    case 'tv':
      return Icons.tv;
    case 'book':
      return Icons.book;
    case 'gym':
      return Icons.fitness_center;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'pets':
      return Icons.pets;

    // Iconos para categorías de ingresos
    case 'money':
      return Icons.attach_money;
    case 'investment':
      return Icons.trending_up;
    case 'wallet':
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
    case 'beach':
      return Icons.beach_access;
    case 'smartphone':
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

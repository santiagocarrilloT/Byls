import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  bool isGastosSelected = true; // Para alternar entre Gastos e Ingresos
  String? selectedCategory; // Para almacenar la categoría seleccionada
  DateTime selectedDate =
      DateTime.now(); // Fecha seleccionada (por defecto, la actual)
  final TextEditingController _cantidadController =
      TextEditingController(); // Controlador para la cantidad
  final TextEditingController _descripcionController =
      TextEditingController(); // Controlador para la descripción
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;
  CuentaController cuentaController = CuentaController();

  final List<Map<String, dynamic>> gastos = [
    {'nombre': 'Casa', 'icono': Icons.home, 'id': 1},
    {'nombre': 'Educación', 'icono': Icons.school, 'id': 2},
    {'nombre': 'Moto', 'icono': Icons.motorcycle, 'id': 3},
    {'nombre': 'Alimentos', 'icono': Icons.fastfood, 'id': 4},
    {'nombre': 'Teléfono', 'icono': Icons.phone_android, 'id': 5},
    {'nombre': 'Gasolina', 'icono': Icons.local_gas_station, 'id': 6},
  ];

  final List<Map<String, dynamic>> ingresos = [
    {'nombre': 'Salario', 'icono': Icons.attach_money, 'id': 7},
    {'nombre': 'Venta', 'icono': Icons.store, 'id': 8},
    {'nombre': 'Inversiones', 'icono': Icons.trending_up, 'id': 9},
  ];

  @override
  void initState() {
    super.initState();
    fetchCuentas();
  }

  // Función para abrir el selector de fecha
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

  IngresosController ingresosController = IngresosController();
  // Crea una instancia de AuthController
  final AuthController authController = AuthController();

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

  @override
  Widget build(BuildContext context) {
    //final authController = Provider.of<AuthController>(context);
    final categories = isGastosSelected ? gastos : ingresos;

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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 7,
              ),
              // Campo para ingresar la cantidad
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Solo números permitidos
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
                    borderSide: const BorderSide(color: Color(0xFF00BFA5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF00BFA5)),
                  ),
                ),
              ),

              // Selector de Gastos e Ingreso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isGastosSelected = true;
                        selectedCategory = null; // Reiniciar la selección
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
                        selectedCategory = null; // Reiniciar la selección
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

              // Categorías
              SizedBox(
                height: 350, // Altura para hacer scroll a las categorias
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Tres columnas
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1, // Ajustar la proporción del ítem
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category['nombre'] == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category['nombre'];
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isSelected
                                ? const Color(0xFF00BFA5)
                                : Colors.grey[300],
                            child: Icon(
                              category['icono'],
                              color: isSelected ? Colors.white : Colors.black,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['nombre'],
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

              // Botón para guardar transacción
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    String idCuentaSelec = (cuentas
                            .firstWhere((element) =>
                                element.idCuenta == selectedCuentaId)
                            .idCuenta)
                        .toString();
                    double saldo = (cuentas
                            .firstWhere((element) =>
                                element.idCuenta == selectedCuentaId)
                            .saldo)
                        .toDouble();
                    try {
                      if (isGastosSelected) {
                        //Insertar gasto
                        await ingresosController.insertarTransaccion(
                            idCuentaSelec,
                            _descripcionController.text,
                            selectedCategory!,
                            double.parse(_cantidadController.text),
                            'Gasto',
                            selectedDate);

                        //Actualizar saldo de la cuenta
                        cuentaController.actualizarSaldo(saldo, idCuentaSelec,
                            double.parse(_cantidadController.text), false);

                        //Mostrar mensaje de gasto guardado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gasto guardado'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        //Redirigir a la pantalla de ingresos
                        context.go("/app_entry");
                      } else {
                        //Insertar ingreso
                        await ingresosController.insertarTransaccion(
                            idCuentaSelec,
                            _descripcionController.text,
                            selectedCategory!,
                            double.parse(_cantidadController.text),
                            'Ingreso',
                            selectedDate);

                        //Actualizar saldo de la cuenta
                        cuentaController.actualizarSaldo(saldo, idCuentaSelec,
                            double.parse(_cantidadController.text), true);

                        //Mostrar mensaje de ingreso guardado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingreso guardado'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        //Redirigir a la pantalla de ingresos
                        context.go("/app_entry");
                      }
                    } catch (e) {
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

import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
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

  bool isGastosSelected = true;
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();
  int? selectedCuentaId;
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    selectedCategory = transaccion.tipoTransaccion;
    selectedDate = transaccion.fechaTransaccion;
    _cantidadController.text = transaccion.montoTransaccion.toString();
    _descripcionController.text = transaccion.descripcion!;
    fetchCuentas();
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
        selectedCuentaId = cuentas[0].idCuenta;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = isGastosSelected ? gastos : ingresos;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/app_entry");
          },
        ),
        title: const Text("Editar Transacción"),
      ),
      backgroundColor: const Color(0xFF006064),
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

              // Botón para guardar transacción
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 191, 188, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
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

                      //Actualizar saldo de la cuenta
                      cuentaController.actualizarSaldo(
                          saldo,
                          idCuentaSelec,
                          double.parse(_cantidadController.text),
                          isGastosSelected ? false : true);

                      //Mostrar mensaje de transacción actualizada
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transacción actualizada con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.go("/app_entry");
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transacción no actualizada'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.edit_document),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

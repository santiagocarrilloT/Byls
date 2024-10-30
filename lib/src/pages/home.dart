import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/controllers/Transaccion_provider.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Para manejar fechas
import 'transaccion.dart'; // Asegúrate de que esta ruta sea correcta

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  IngresosController ingresosController = IngresosController();
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;
  double saldoCuenta = 0.0;
  final List<bool> _selections = List.generate(5, (_) => false);
  List<IncomeModel> futureIngresos = [];
  String selectedType = 'Ingreso'; // Tipo de transacción seleccionada
  DateTime? selectedDate; // Fecha seleccionada para filtrar
  String selectedPeriod = 'Día'; // Periodo seleccionado

  @override
  void initState() {
    super.initState();
    fetchCuentas();
    fetchTransacciones();
  }

  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        selectedCuentaId = cuentas[0].idCuenta;
        cargarSaldoCuenta(selectedCuentaId!);
      }
    });
  }

  Future<void> cargarSaldoCuenta(int cuentaId) async {
    final cuentaSeleccionada =
        cuentas.firstWhere((cuenta) => cuenta.idCuenta == cuentaId);
    setState(() {
      saldoCuenta = cuentaSeleccionada.saldo;
    });
  }

  void fetchTransacciones() async {
    try {
      List<IncomeModel> transacciones =
          await IncomeModel.getTodasTransacciones();
      setState(() {
        futureIngresos = transacciones;
      });
    } catch (e) {
      print('Error fetching transacciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar transacciones según el tipo seleccionado y el periodo
    List<IncomeModel> filteredTransacciones = futureIngresos
        .where((transaccion) => transaccion.tipoTransaccion == selectedType)
        .toList();

    // Aplicar filtro por periodo
    DateTime now = DateTime.now();
    if (selectedPeriod == 'Día') {
      filteredTransacciones = filteredTransacciones.where((transaccion) =>
          transaccion.fechaTransaccion
              .isAfter(DateTime(now.year, now.month, now.day))).toList();
    } else if (selectedPeriod == 'Semana') {
      filteredTransacciones = filteredTransacciones.where((transaccion) =>
          transaccion.fechaTransaccion
              .isAfter(now.subtract(const Duration(days: 7)))).toList();
    } else if (selectedPeriod == 'Mes') {
      filteredTransacciones = filteredTransacciones.where((transaccion) =>
          transaccion.fechaTransaccion
              .isAfter(DateTime(now.year, now.month - 1, now.day))).toList();
    } else if (selectedPeriod == 'Año') {
      filteredTransacciones = filteredTransacciones.where((transaccion) =>
          transaccion.fechaTransaccion
              .isAfter(DateTime(now.year - 1, now.month, now.day))).toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(230, 91, 255, 173),
        title: Center(
          child: DropdownButton<int>(
            value: selectedCuentaId,
            icon: const Icon(Icons.arrow_downward),
            onChanged: (int? newValue) {
              setState(() {
                selectedCuentaId = newValue;
                cargarSaldoCuenta(selectedCuentaId!);
              });
            },
            items: cuentas.map<DropdownMenuItem<int>>((CuentaModel cuenta) {
              return DropdownMenuItem<int>(
                value: cuenta.idCuenta,
                child: Text(cuenta.nombreCuenta),
              );
            }).toList(),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(230, 91, 255, 173)),
          Positioned(
            top: 1,
            left: 0,
            right: 0,
            child: Center(
              child: SaldoDisplay(saldoCuenta: saldoCuenta),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.10 + 10,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF006064),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'Gasto'; // Cambia el tipo a Gasto
                          });
                        },
                        child: Text(
                          'Gastos',
                          style: TextStyle(
                            color: selectedType == 'Gasto' ? Colors.yellow : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'Ingreso'; // Cambia el tipo a Ingreso
                          });
                        },
                        child: Text(
                          'Ingreso',
                          style: TextStyle(
                            color: selectedType == 'Ingreso' ? Colors.yellow : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Seleccionar periodo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ToggleButtons(
                          borderRadius: BorderRadius.circular(10),
                          isSelected: _selections,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Día'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Semana'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Mes'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Año'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Periodo'),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _selections.length; i++) {
                                _selections[i] = i == index;
                              }
                              // Cambiar el periodo seleccionado
                              if (index == 0) selectedPeriod = 'Día';
                              if (index == 1) selectedPeriod = 'Semana';
                              if (index == 2) selectedPeriod = 'Mes';
                              if (index == 3) selectedPeriod = 'Año';
                              if (index == 4) selectedPeriod = 'Periodo';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTransacciones.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            border: Border.all(color: const Color(0xFF00BFA5)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(
                              filteredTransacciones[index].nombreTransaccion,
                              style: const TextStyle(fontSize: 20),
                            ),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(filteredTransacciones[index]
                                      .fechaTransaccion),
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              filteredTransacciones[index].tipoTransaccion ==
                                      'Ingreso'
                                  ? '+${filteredTransacciones[index].monto}'
                                  : '-${filteredTransacciones[index].monto}',
                              style: TextStyle(
                                fontSize: 18,
                                color: filteredTransacciones[index]
                                            .tipoTransaccion ==
                                        'Ingreso'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de transacción
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Transaccion()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF00BFA5),
      ),
    );
  }
}

class SaldoDisplay extends StatelessWidget {
  final double saldoCuenta;

  const SaldoDisplay({Key? key, required this.saldoCuenta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Saldo disponible',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${saldoCuenta.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

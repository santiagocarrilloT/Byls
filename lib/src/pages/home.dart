import 'package:byls_app/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/controllers/Transaccion_provider.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Inicializar cambio en formato del saldo
  FormatoUtils formatoUtils = FormatoUtils();

  //Inicializar controlador de ingresos
  IngresosController ingresosController = IngresosController();
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;
  double saldoCuenta = 0.0;
  String tipoMoneda = 'USD';
  final List<bool> _selections = List.generate(4, (_) => false);

  List<IncomeModel> futureIngresos = [];
  String selectedType =
      'Ingreso'; // Variable para gestionar el tipo de transacción

  @override
  void initState() {
    super.initState();
    fetchCuentas();
    //fetchTransacciones();
  }

  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        selectedCuentaId = cuentas[0].idCuenta;
        tipoMoneda = cuentas[0].tipoMoneda!;
        cargarTransacciones();
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

  Future<void> cargarTransacciones() async {
    try {
      List<IncomeModel> transaccionesFiltro =
          await IncomeModel.getTransacciones(selectedCuentaId!);
      setState(() {
        futureIngresos = transaccionesFiltro;
      });
    } catch (e) {
      print('Error fetching transacciones: $e');
    }
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
    // Filtrar transacciones según el tipo seleccionado
    List<IncomeModel> filteredTransacciones = futureIngresos
        .where((transaccion) => transaccion.tipoTransaccion == selectedType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton(
                value: selectedCuentaId,
                icon:
                    const Icon(Icons.arrow_downward, color: Color(0xFFFFFFFF)),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Color(0xFFFFFFFF)),
                dropdownColor: const Color(0xFFFFFFFF),
                underline: Container(
                  height: 2,
                  color: const Color(0xFFFFFFFF),
                ),
                onChanged: (int? newValue) {
                  setState(
                    () {
                      selectedCuentaId = newValue;
                      cargarSaldoCuenta(selectedCuentaId!);
                      cargarTransacciones();
                    },
                  );
                },
                items: cuentas.map<DropdownMenuItem<int>>((CuentaModel cuenta) {
                  return DropdownMenuItem<int>(
                    value: cuenta.idCuenta,
                    child: Text(
                      cuenta.nombreCuenta,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  );
                }).toList(),
                borderRadius: BorderRadius.circular(10.0),
              ),

              const SizedBox(width: 10),

              // Botón para crear nueva cuenta
              IconButton(
                icon: const Icon(Icons.post_add, color: Color(0xFFFFFFFF)),
                onPressed: () {
                  context.go('/NuevaCuenta');
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF00BFA5)),
          Positioned(
            top: 1,
            left: 0,
            right: 0,
            child: Center(
              child: SaldoDisplay(
                saldoCuenta: saldoCuenta,
                divisa: tipoMoneda,
                formatoUtils: formatoUtils,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.10 + 10,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF006064), //Color(0xFF00A5B5),
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
                            color: selectedType == 'Gasto'
                                ? const Color(0xFFb4f4bc)
                                : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType =
                                'Ingreso'; // Cambia el tipo a Ingreso
                          });
                        },
                        child: Text(
                          'Ingreso',
                          style: TextStyle(
                            color: selectedType == 'Ingreso'
                                ? const Color(0xFFb4f4bc)
                                : Colors.white,
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
                      color: const Color(0xFF00BFA5),
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
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _selections.length; i++) {
                                _selections[i] = i == index;
                              }
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
                            color: const Color(0xFFb4f4bc),
                            border: Border.all(color: const Color(0xFF00BFA5)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(
                              '${filteredTransacciones[index].nombreCategoria}',
                              style: const TextStyle(color: Color(0xFF4E4E4E)),
                            ),
                            leading: Hero(
                              tag: index,
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child:
                                    Icon(Icons.house, color: Color(0xFF4E4E4E)),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$ ${filteredTransacciones[index].montoTransaccion}',
                                  style: const TextStyle(
                                    color: Color(0xFF4E4E4E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                /* IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      await ingresosController.deleteIngreso(
                                          filteredTransacciones[index]
                                              .idTransaccion
                                              .toString());
                                      setState(() {
                                        filteredTransacciones.removeAt(index);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Transacción eliminada correctamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      context.go('/app_entry');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Error al eliminar transacción'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                             */
                              ],
                            ),
                            onTap: () {
                              final transaccionProvider =
                                  Provider.of<TransaccionProvider>(context,
                                      listen: false);
                              transaccionProvider.setCurrentTransaccion(
                                  filteredTransacciones[index]);
                              context.go('/transaccionEdit',
                                  extra: filteredTransacciones[index]);
                            },
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navegar a la pantalla de transacción
              context.go('/transaccion');
            },
            child: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}

class SaldoDisplay extends StatelessWidget {
  final double saldoCuenta;
  final String? divisa;
  final FormatoUtils formatoUtils;

  const SaldoDisplay(
      {super.key,
      required this.saldoCuenta,
      required this.divisa,
      required this.formatoUtils});

  @override
  Widget build(BuildContext context) {
    return saldoCuenta >= 0
        ? Text(
            '\$ ${formatoUtils.formatNumber(saldoCuenta)} $divisa',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFb4f4bc),
            ),
          )
        : Text(
            '\$ -${formatoUtils.formatNumber(saldoCuenta * (-1))} $divisa',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 224, 17, 17),
            ),
          );
  }
}

import 'dart:math';

import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/src/pages/componentsReport.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReportsUser extends StatefulWidget {
  const ReportsUser({super.key});

  @override
  State<ReportsUser> createState() => _ReportsUserState();
}

class _ReportsUserState extends State<ReportsUser> {
  Componentsreport componentsreports = Componentsreport();
  double widthPantalla = 0.0;
  double heightPantalla = 0.0;

  List<IncomeModel> dataTransacciones = [];
  List<double> transaccionesSuma = [0, 0];

  bool habilitarSaldoPos = false;
  List<double> saldoCuentasPositivo = [
    0.0 /*, 0.0 , 12000, 23000, 0.0, 314000 */
  ];
  List<double> saldoCuentasNegativo = [-20000];
  List<DateTime> fechasPositivo = [
    /* DateTime.now().subtract(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 4)),
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 2)),*/
    DateTime.now().subtract(const Duration(days: 1)),
  ];
  List<DateTime> fechasNegativo = [
    DateTime.now().subtract(const Duration(days: 1)),
  ];
  String? fechaResumen = 'Mes';
  DateTime now = DateTime.now();
  DateTime rangoFechas = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchTotalCuentas();

    if (fechaResumen != null) {
      fetchTransacciones(fechaResumen!);
      rangoFechasResumen();
    } else {
      fetchTransacciones('Mes');
      rangoFechasResumen();
    }
  }

  Future<void> fetchTotalCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.saldoTotalUsuario(userId!);
    setState(() {
      for (var cuenta in cuentasUsuario) {
        if (cuenta['total'] as double >= 0) {
          saldoCuentasPositivo.add(cuenta['total'] as double);
          fechasPositivo.add(cuenta['fecha'] as DateTime);
        } else {
          saldoCuentasNegativo.add(cuenta['total'] as double);
          fechasNegativo.add(cuenta['fecha'] as DateTime);
        }
      }

      /* saldoCuentas =
          cuentasUsuario.map((cuenta) => cuenta['total'] as double).toList(); */

      /* fechas =
          cuentasUsuario.map((cuenta) => cuenta['fecha'] as DateTime).toList(); */
    });
  }

  // Función para las transacciones totales
  void fetchTransacciones(String fechaResumen) async {
    try {
      List<IncomeModel> transacciones =
          await IncomeModel.getTransaccionesFiltradasPorPeriodo(fechaResumen);

      setState(() {
        dataTransacciones = transacciones;
        sumarTransacciones(dataTransacciones);
      });
    } catch (e) {
      print('Error fetching transacciones: $e');
    }
  }

  // Función para sumar el total de las transacciones entre Ingresos y Egresos
  void sumarTransacciones(List<IncomeModel> dataTransacciones) {
    for (var transaccion in dataTransacciones) {
      if (transaccion.tipoTransaccion == 'Ingreso') {
        transaccionesSuma[0] += transaccion.cantidadTransaccion;
      } else {
        transaccionesSuma[1] += transaccion.cantidadTransaccion;
      }
    }
  }

  void rangoFechasResumen() {
    switch (fechaResumen) {
      case 'Día':
        setState(() {
          rangoFechas = DateTime(now.year, now.month, now.day);
        });
        break;
      case 'Semana':
        setState(() {
          rangoFechas = now.subtract(Duration(days: now.weekday - 1));
        });
        break;
      case 'Mes':
        setState(() {
          rangoFechas = DateTime(now.year, now.month, 1);
        });
        break;
      case 'Año':
        setState(() {
          rangoFechas = DateTime(now.year, 1, 1);
        });
        break;
      default:
        throw ArgumentError('Periodo no válido');
    }
  }

  @override
  Widget build(BuildContext context) {
    widthPantalla = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF006064),
        //Modificar tamaño de la barra de navegación
        toolbarHeight: 0.0,
      ),
      body: SingleChildScrollView(
        child: Builder(builder: (context) {
          return Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    // Resumen (Grafica Pastel)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Container(
                            width: widthPantalla * 0.9,
                            height: 190,
                            color: const Color.fromARGB(183, 0, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        '$fechaResumen Actual',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      //Centrar el padding verticalmente
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: transaccionesSuma.isEmpty
                                            ? const Text('Aún no hay datos')
                                            : _buildPieChart(transaccionesSuma),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 45,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(right: 11.0),
                                        child: Text(
                                          'Ingreso:',
                                          style: TextStyle(color: Colors.green),
                                        )),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 11.0),
                                      child: Text(
                                        'Egreso:',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 11.0),
                                      child: Text(
                                        transaccionesSuma.isEmpty
                                            ? 'Aún no hay datos'
                                            : 'Total:',
                                        style: (transaccionesSuma[0] -
                                                    transaccionesSuma[1]) >=
                                                0
                                            ? const TextStyle(
                                                color: Colors.green)
                                            : const TextStyle(
                                                color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child:
                                      Container(), // Ocupa el espacio restante
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 45,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 11.0),
                                      child: Text(
                                        transaccionesSuma.isEmpty
                                            ? '-'
                                            : '\$${transaccionesSuma[0]}',
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 11.0),
                                      child: Text(
                                        transaccionesSuma.isEmpty
                                            ? '-'
                                            : '\$-${transaccionesSuma[1]}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 11.0),
                                      child: Text(
                                        transaccionesSuma.isEmpty
                                            ? '-'
                                            : '\$${transaccionesSuma[0] - transaccionesSuma[1]}',
                                        style: (transaccionesSuma[0] -
                                                    transaccionesSuma[1]) >=
                                                0
                                            ? const TextStyle(
                                                color: Colors.green)
                                            : const TextStyle(
                                                color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          //Título de la gráfica
                          Container(
                            width: widthPantalla * 0.9,
                            height: 30,
                            alignment: Alignment.center,
                            child: const Text(
                              'Resumen Transacciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Ícono en la esquina superior derecha
                          Positioned(
                            top: 28,
                            right: 10,
                            child: IconButton(
                              onPressed: () {
                                showValidateOTPResumen(context);
                              },
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                              ),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //Balance (Grafica de Línea)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Container(
                            width: widthPantalla * 0.9,
                            height: 230,
                            color: const Color.fromARGB(183, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 36,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: habilitarSaldoPos
                                          ? const Text(
                                              'Balance Positivo',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Balance Negativo',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 28,
                                ),

                                // Gráfica de líneas
                                habilitarSaldoPos
                                    ? Center(
                                        child: SizedBox(
                                          width: widthPantalla * 0.8,
                                          height: 125,
                                          child: saldoCuentasPositivo.isEmpty ||
                                                  saldoCuentasPositivo.length ==
                                                      1
                                              ? const Center(
                                                  child: Text(
                                                    'Aún no hay datos',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                )
                                              : _buildLineChart(fechasPositivo,
                                                  saldoCuentasPositivo),
                                        ),
                                      )
                                    : Center(
                                        child: SizedBox(
                                          width: widthPantalla * 0.8,
                                          height: 125,
                                          child: saldoCuentasNegativo.isEmpty ||
                                                  saldoCuentasNegativo.length ==
                                                      1
                                              ? const Center(
                                                  child: Text(
                                                    'No hay balance negativo',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                )
                                              : _buildLineChart(fechasNegativo,
                                                  saldoCuentasNegativo),
                                        ),
                                      )
                              ],
                            ),
                          ),
                          //Título de la gráfica
                          Container(
                            width: widthPantalla * 0.9,
                            height: 32,
                            alignment: Alignment.center,
                            child: const Text(
                              'Balance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Ícono en la esquina superior derecha
                          Positioned(
                            top: 25,
                            right: 10,
                            child: IconButton(
                              onPressed: () {
                                showValidateOTPBalance(
                                    context, habilitarSaldoPos ? 'Pos' : 'Neg');
                              },
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                              ),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //Transacciones (Gráfica de Pastel)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: widthPantalla * 0.9,
                        height: 190,
                        color: const Color.fromARGB(183, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Alineación vertical general
                          children: [
                            // Título de la gráfica
                            const Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      5.0), // Espaciado superior para el título
                              child: Text(
                                'Resumen transacciones por cuenta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.go('/graficos'),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Centra verticalmente
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ), // Espaciado izquierdo
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        'Toca para explorar\ningresos y egresos\nen detalle',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Spacer(), // Empuja el gráfico hacia la derecha
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.blue,
                                              value: 33,
                                              title: '',
                                            ),
                                            PieChartSectionData(
                                              color: Colors.yellow,
                                              value: 33,
                                              title: '',
                                            ),
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: 33,
                                              title: '',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Spacer(), // Asegura un balance entre texto y gráfico
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  //Función para construir la gráfica de líneas
  Widget _buildLineChart(List<DateTime> fechas, List<double> saldoCuentas) {
    int ind = -1;
    return LineChart(
      LineChartData(
        // Configuración de los ejes
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < fechas.length && index != ind) {
                  ind = index;
                  // Asegúrate de no exceder el límite
                  return Text(
                    DateFormat('MM/dd').format(fechas[index]),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 100000,
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "\$${value.toInt()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.white),
            bottom: BorderSide(color: Colors.white),
          ),
        ),
        // Límites del gráfico
        minX: 0,
        maxX: fechas.length.toDouble(),

        minY: habilitarSaldoPos
            ? 0
            : saldoCuentas.reduce((a, b) => a < b ? a : b) - 100,

        maxY: habilitarSaldoPos
            ? saldoCuentas.reduce((a, b) => a > b ? a : b) + 500
            : saldoCuentas.reduce((a, b) => a > b ? a : b) + 500,
        // Datos de la gráfica
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(fechas.length, (index) {
              // Convertimos las fechas en índices del eje X
              return FlSpot(index.toDouble(), saldoCuentas[index]);
            }),
            isCurved: true,
            gradient: habilitarSaldoPos
                ? const LinearGradient(colors: [Colors.blue, Colors.purple])
                : const LinearGradient(colors: [Colors.red, Colors.purple]),
            belowBarData: BarAreaData(
              show: true,
              gradient: habilitarSaldoPos
                  ? LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.purple.withOpacity(0.1),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.purple.withOpacity(0.1),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

//Función para mostrar un diálogo de confirmación para cambiar las fechas de la gráfica
  showValidateOTPBalance(BuildContext context, String tipoBalance) {
    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>(const Color(0xFF838282)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
      },
      child: const Text(
        "No",
        style: TextStyle(color: Colors.white),
      ),
    );

    Widget continueButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      onPressed: () async {
        setState(() {
          tipoBalance == 'Pos'
              ? habilitarSaldoPos = true
              : habilitarSaldoPos = false;
        });

        // Cerrar el diálogo
        Navigator.of(context).pop();
      },
      child: const Text("Si", style: TextStyle(color: Colors.white)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tipo de Balance:"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<String>(
                value: tipoBalance,
                onChanged: (String? newValue) {
                  setState(() {
                    tipoBalance = newValue!;
                    tipoBalance == 'Pos'
                        ? habilitarSaldoPos = true
                        : habilitarSaldoPos = false;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Pos',
                    child: Text('Balance Positivo'),
                  ),
                  DropdownMenuItem(
                    value: 'Neg',
                    child: Text('Balance Negativo'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Signo Balance:',
                  labelStyle: const TextStyle(
                    color: Color(0xFF00BFA5),
                  ),
                  prefixIcon: const Icon(
                    Icons.watch_later,
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
              );
            },
          ),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }

  // Función para construir una gráfica dinámica basada en los valores de la categoría
  Widget _buildPieChart(List<double> data) {
    if (data[0] == 0 && data[1] == 0) {
      return Container(
        alignment: Alignment.center,
        child: const Text(
          'Aún no hay datos',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: data[0],
              title: '',
            ),
            PieChartSectionData(
              color: Colors.red,
              value: data[1],
              title: '',
            ),
          ],
        ),
      );
    }
  }

//Función para mostrar un diálogo de confirmación para cambiar las fechas de la gráfica
  showValidateOTPResumen(BuildContext context) {
    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>(const Color(0xFF838282)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
      },
      child: const Text(
        "No",
        style: TextStyle(color: Colors.white),
      ),
    );

    Widget continueButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      onPressed: () async {
        transaccionesSuma = [0, 0];
        fetchTransacciones(fechaResumen!);
        rangoFechasResumen();
        // Cerrar el diálogo
        Navigator.of(context).pop();
      },
      child: const Text("Si", style: TextStyle(color: Colors.white)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modificar Fecha Resumen:"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<String>(
                value: fechaResumen,
                onChanged: (String? newValue) {
                  setState(() {
                    fechaResumen = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Día',
                    child: Text('Día Actual'),
                  ),
                  DropdownMenuItem(
                    value: 'Semana',
                    child: Text('Semana Actual'),
                  ),
                  DropdownMenuItem(
                    value: 'Mes',
                    child: Text('Mes Actual'),
                  ),
                  DropdownMenuItem(
                    value: 'Año',
                    child: Text('Año Actual'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Fecha:',
                  labelStyle: const TextStyle(
                    color: Color(0xFF00BFA5),
                  ),
                  prefixIcon: const Icon(
                    Icons.watch_later,
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
              );
            },
          ),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }
}

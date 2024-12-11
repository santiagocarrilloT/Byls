import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transferencia_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TranfersHistory extends StatefulWidget {
  const TranfersHistory({super.key});

  @override
  State<TranfersHistory> createState() => _TranfersHistoryState();
}

class _TranfersHistoryState extends State<TranfersHistory> {
  int? selectedCuentaId;
  String selectedPeriodo = 'T';
  List<TransferenciaModel> futureTransferencias = [];
  Map<int, String> nombreCuentas = {};

  @override
  void initState() {
    super.initState();

    informacionTrasnferencias();
    informacionCuentas();
  }

  void informacionTrasnferencias() async {
    try {
      List<TransferenciaModel> transferenciasUser =
          await TransferenciaModel.getTransferencias();
      setState(() {
        futureTransferencias = transferenciasUser;
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void informacionCuentas() async {
    try {
      Map<int, String> cuentas = await CuentaModel.cuentasPorNombre();
      setState(() {
        nombreCuentas = cuentas;
        print(nombreCuentas);
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void cargarTransferenciasCuentaOrigen(int idCuenta) async {
    try {
      List<TransferenciaModel> transferenciasUser =
          await TransferenciaModel.cargarTransferenciasPorCuentaOrigen(
              idCuenta);
      setState(() {
        futureTransferencias = transferenciasUser;
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void cargarTransaccionesFecha(String periodo) async {
    try {
      List<TransferenciaModel> transferenciasUser =
          await TransferenciaModel.cargarTransferenciasPorFecha(periodo);
      setState(() {
        futureTransferencias = transferenciasUser;
      });
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF044454),
        leading: IconButton(
            onPressed: () {
              context.go('/app_entry', extra: 2);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white)),
        title: const Text('Historial Transferencias',
            style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: const Color(0xFF04242C),
      body: futureTransferencias.isEmpty
          ? Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          showValidateCambiarCuenta(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF044454), // Color de fondo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Redondea la esquina superior izquierda
                          ),
                        ),
                        iconAlignment: IconAlignment.start,
                        child: const Text(
                          'Cuenta',
                          style: TextStyle(color: Colors.white, fontSize: 14.5),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          showValidateCambiarPeriodo(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF044454),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        iconAlignment: IconAlignment.start,
                        child: const Text(
                          'Fecha',
                          style: TextStyle(color: Colors.white, fontSize: 14.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Center(
                    child: Text(
                  'No se encontraron transferencias',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
              ],
            )
          : Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          showValidateCambiarCuenta(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF044454), // Color de fondo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Redondea la esquina superior izquierda
                          ),
                        ),
                        iconAlignment: IconAlignment.start,
                        child: const Text(
                          'Cuenta',
                          style: TextStyle(color: Colors.white, fontSize: 14.5),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          showValidateCambiarPeriodo(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF044454),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        iconAlignment: IconAlignment.start,
                        child: const Text(
                          'Fecha',
                          style: TextStyle(color: Colors.white, fontSize: 14.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: futureTransferencias.length,
                    itemBuilder: (BuildContext context, int index) {
                      //Margen y decoración de la lista
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF044454),
                          border: Border.all(color: const Color(0xFF006064)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${futureTransferencias[index].fechaTransferencia.day}/${futureTransferencias[index].fechaTransferencia.month}/${futureTransferencias[index].fechaTransferencia.year}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            ListTile(
                              title: Text(
                                nombreCuentas[futureTransferencias[index]
                                        .idCuentaOrigen]
                                    .toString(),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 14.5,
                                ),
                              ),
                              leading: Hero(
                                tag: index,
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      right: 4.0, left: 4.0, bottom: 4.0),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$ ${futureTransferencias[index].cantidad.toString()}',
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 14.5),
                                  )
                                ],
                              ),
                              onTap: () {
                                showValidateMostrarTransferencia(
                                    context, futureTransferencias[index]);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  //Función para mostrar un diálogo con la información de la transferencia
  showValidateMostrarTransferencia(
      BuildContext context, TransferenciaModel futureTransferencias) {
    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
            const Color.fromARGB(255, 255, 255, 255)),
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
        "Volver",
        style: TextStyle(color: Colors.black),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Detalles de la Transferencia",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF044454),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cuenta origen de la transferencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCE000000),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.send,
                      size: 17,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Origen: ${nombreCuentas[futureTransferencias.idCuentaOrigen]}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // Cuenta destino de la transferencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCE000000),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.download,
                      size: 17,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Destino: ${nombreCuentas[futureTransferencias.idCuentaDestino]}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              //Cantidad de la transferencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCE000000),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 17,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      'Cantidad: ${futureTransferencias.cantidad}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              //Fecha de la transferencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCE000000),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 17,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      'Fecha: ${futureTransferencias.fechaTransferencia.day}/${futureTransferencias.fechaTransferencia.month}/${futureTransferencias.fechaTransferencia.year}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              //Descripción de la transferencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCE000000),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description,
                      size: 17,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      'Descripción: ${futureTransferencias.descripcion}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            cancelButton,
          ],
        );
      },
    );
  }

  //Función para mostrar un diálogo de confirmación para cambiar las fechas de las transferencias
  showValidateCambiarPeriodo(BuildContext context) {
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
        "Volver",
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
        if (selectedPeriodo == 'T') {
          informacionTrasnferencias();
        } else {
          cargarTransaccionesFecha(selectedPeriodo);
        }
        // Cerrar el diálogo
        Navigator.of(context).pop();
      },
      child: const Text("Buscar", style: TextStyle(color: Colors.white)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Filtrar Transferencias por Periodo de Tiempo",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF04242C),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                // Dropdown para seleccionar cuenta
                value: selectedPeriodo,
                icon: const Icon(Icons.arrow_downward, color: Colors.white),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF04242C),
                onChanged: (String? newValue) {
                  setState(
                    () {
                      selectedPeriodo = newValue!;
                    },
                  );
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
                  DropdownMenuItem(
                    value: 'T',
                    child: Text('Todas'),
                  ),
                ],
                /* focusColor: const Color.fromARGB(255, 0, 0, 0), */
                borderRadius: BorderRadius.circular(10.0),
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

  //Función para mostrar un diálogo de confirmación para cambiar las cuentas de origen de las transferencias
  showValidateCambiarCuenta(BuildContext context) {
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
        "Volver",
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
        if (selectedCuentaId == -1) {
          informacionTrasnferencias();
        } else {
          cargarTransferenciasCuentaOrigen(selectedCuentaId!);
        }
        // Cerrar el diálogo
        Navigator.of(context).pop();
      },
      child: const Text("Buscar", style: TextStyle(color: Colors.white)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Filtrar Transferencias por Cuenta de Origen",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF04242C),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton(
                // Dropdown para seleccionar cuenta
                value: selectedCuentaId,
                icon: const Icon(Icons.arrow_downward, color: Colors.white),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF04242C),
                onChanged: (int? newValue) {
                  setState(
                    () {
                      selectedCuentaId = newValue;
                    },
                  );
                },
                items: getDropdownCuentas(),
                //focusColor: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(10.0),
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

  //Método para obtener las cuentas de un usuario por su UID
  List<DropdownMenuItem<int>> getDropdownCuentas() {
    List<DropdownMenuItem<int>> items = [];
    nombreCuentas.forEach((key, value) {
      items.add(
        DropdownMenuItem<int>(
          value: key,
          child: Text(
            value,
          ),
        ),
      );
    });
    //Añadir la opción al final del DropDown de mostrar todas las cuentas
    items.add(
      const DropdownMenuItem<int>(
        value: -1,
        child: Text(
          'Todas',
        ),
      ),
    );
    return items;
  }
}

import 'package:byls_app/models/cuenta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Opciones extends StatefulWidget {
  static bool habilitarPuntuacion = false;
  static int? selectedCuentaId;

  static Future<void> saveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('habilitarPuntuacion', Opciones.habilitarPuntuacion);
    prefs.setInt('selectedCuentaId', Opciones.selectedCuentaId!);
  }

  static Future<bool?> loadPuntuacion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('habilitarPuntuacion');
  }

  static Future<int?> loadCuenta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedCuentaId');
  }

  static Future<void> removeValue() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('habilitarPuntuacion');
    prefs.remove('selectedCuentaId');
  }

  const Opciones({super.key});

  @override
  State<Opciones> createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
  Map<int, String> nombreCuentas = {};

  @override
  void initState() {
    super.initState();

    informacionCuentas();
  }

  void informacionCuentas() async {
    try {
      Map<int, String> cuentas = await CuentaModel.cuentasPorNombre();
      setState(() {
        nombreCuentas = cuentas;
      });
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pushReplacement('/app_entry', extra: 3);
          },
        ),
        title: const Text('Ajustes'),
      ),
      body: Container(
        color: const Color(0xFF006064),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ListTile(
              title: const Text(
                'Cambiar Divisas',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.currency_exchange_outlined,
                color: Colors.white,
              ),
              onTap: () => {
                context.go('/cambiarDivisas'),
              },
            ),
            ListTile(
              title: const Text(
                'Cuenta Inicial',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.star,
                color: Colors.white,
              ),
              onTap: () => {
                if (Opciones.selectedCuentaId == 0)
                  {
                    showValidateCambiarCuenta(
                        context, nombreCuentas.keys.first),
                  }
                else
                  {
                    showValidateCambiarCuenta(
                        context, Opciones.selectedCuentaId),
                  }
              },
            ),
            ListTile(
              title: const Text(
                'Habilitar Puntuación a Saldos',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.remove_red_eye,
                color: Colors.white,
              ),
              trailing: Switch(
                activeColor: const Color(0xFFFF8A65),
                value: Opciones.habilitarPuntuacion,
                onChanged: (value) {
                  setState(() {
                    Opciones.habilitarPuntuacion = value;
                  });
                  //Guardar el valor de la puntuación a saldos en las preferencias
                  Opciones.saveValue();
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Puntuación a saldos habilitada'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Puntuación a saldos deshabilitada'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Función para mostrar un diálogo de confirmación para seleccionar una cuenta inicial
  showValidateCambiarCuenta(BuildContext context, int? cuentaSeleccionada) {
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
        Opciones.selectedCuentaId = cuentaSeleccionada;

        //Guardar la cuenta seleccionada en las preferencias
        Opciones.saveValue();

        //Mensaje de confirmación al seleccionar una cuenta inicial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${nombreCuentas[cuentaSeleccionada]} seleccionada como cuenta inicial'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        // Cerrar el diálogo
        Navigator.of(context).pop();
      },
      child: const Text("Elegir Cuenta", style: TextStyle(color: Colors.white)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Seleccionar una cuenta inicial",
            style: TextStyle(fontSize: 18.0),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton(
                // Dropdown para seleccionar cuenta
                value: cuentaSeleccionada,
                icon: const Icon(Icons.arrow_downward,
                    color: Color.fromARGB(255, 0, 0, 0)),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                dropdownColor: const Color(0xFFFFFFFF),
                onChanged: (int? newValue) {
                  setState(
                    () {
                      cuentaSeleccionada = newValue;
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

    return items;
  }
}

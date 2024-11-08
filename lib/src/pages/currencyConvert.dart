import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cambioDivisa_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/services/conversorMoneda_service.dart';
import 'package:byls_app/services/exchange_rate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ConversorDivisas extends StatefulWidget {
  const ConversorDivisas({super.key});

  @override
  State<ConversorDivisas> createState() => _ConversorDivisasState();
}

class _ConversorDivisasState extends State<ConversorDivisas> {
  double widthPantalla = 0;
  String? divisaActual;
  List<CuentaModel>? cuenta;

  @override
  void initState() {
    super.initState();
    informacionCuentas();
  }

  void informacionCuentas() async {
    try {
      final userId =
          Provider.of<AuthController>(context, listen: false).currentUser?.id;
      List<CuentaModel> cuentasUsuario = await CuentaModel.getCuentas(userId!);
      setState(() {
        cuenta = cuentasUsuario;
        divisaActual = cuenta![0].tipoMoneda;
      });
    } catch (e) {
      print('Error fetching cuentas: $e');
    }
  }

  //final TextEditingController _montoController = TextEditingController();
  // String _from = 'USD';
  //String _to = 'EUR';
  //double? _result;
  double? _cantidadConversion;
  final _currencyService = ConversorService();

  Future<void> _convertCurrency(tipoCambio) async {
    setState(() {
      //_result = null; // Reinicia el resultado cuando empieza la conversión
      _cantidadConversion = null;
    });

    try {
      //final double amount = double.parse(_montoController.text);
      final ExchangeRate exchangeRate =
          await _currencyService.getChangeRate(divisaActual!, tipoCambio);
      setState(() {
        //_result = amount * exchangeRate.cantidad;
        //_conversorModel = ConversorModel(cantidadConversion: amount);
        _cantidadConversion = exchangeRate.cantidad;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    widthPantalla = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF63F77D),
          title: const Text('Cambiar Divisas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              GoRouter.of(context).pushReplacement('/settings');
            },
          ),
        ),
        body: Container(
          color: const Color(0xFF124C2D),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: widthPantalla * 0.1,
                  height: 80,
                  color: const Color.fromARGB(129, 50, 173, 240),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Divisa Actual',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(176, 255, 255, 255)),
                      ),
                      Text(
                        '$divisaActual',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.white,
                thickness: 1.5,
              ),
              const SizedBox(height: 5),
              const Text(
                'Convertir a: ',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              divisasDisponibles('USD'),
              const SizedBox(height: 5),
              divisasDisponibles('EUR'),
              const SizedBox(height: 5),
              divisasDisponibles('GBP'),
              const SizedBox(height: 5),
              divisasDisponibles('CAD'),
              const SizedBox(height: 5),
              divisasDisponibles('PLN'),
              const SizedBox(height: 5),
              divisasDisponibles('COP'),
            ],
          ),
        )
        /* Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _montoController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _from,
                  items: <String>['USD', 'EUR', 'GBP', 'CAD', 'PLN', 'COP']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _from = newValue!;
                    });
                  },
                ),
                const Icon(Icons.arrow_forward),
                DropdownButton<String>(
                  value: _to,
                  items: <String>['USD', 'EUR', 'GBP', 'CAD', 'PLN', 'COP']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  focusColor: Colors.white,
                  onChanged: (newValue) {
                    setState(() {
                      _to = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      await _convertCurrency();

                      CambiosDivisaController conversorModel =
                          CambiosDivisaController(
                              cantidadConversion: _cantidadConversion!,
                              tipoMoneda: _to);
                      /* CambiosDivisaController conversorModel =
                          CambiosDivisaController(
                              cantidadConversion: 1.0, tipoMoneda: _to); */
                      conversorModel.convertirDivisas();

                      //context.go('/');
                    },
                    child: const Text(
                      'Convertir',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
            const SizedBox(height: 16),
            if (_result != null)
              Text(
                'Resultado: $_result $_to',
                style: const TextStyle(fontSize: 24),
              ),
          ],
        ),
      ), */
        );
  }

  ClipRRect divisasDisponibles(String nuevaDivisa) {
    if (nuevaDivisa != divisaActual) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: const Color.fromARGB(75, 50, 173, 240),
          child: ListTile(
            title: Text(
              nuevaDivisa,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              showValidateOTP(context, nuevaDivisa);
            },
          ),
        ),
      );
    } else {
      //Retornar el componente inhabilitado
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: const Color.fromRGBO(50, 173, 240, 0.161),
          child: ListTile(
            enabled: false,
            title: Text(
              nuevaDivisa,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  showValidateOTP(BuildContext context, String nuevaDivisa) {
    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
      },
      child: const Text("No"),
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
        //Funciona correctamente el cambio de divisa
        await _convertCurrency(nuevaDivisa);

        CambiosDivisaController conversorModel = CambiosDivisaController(
            cantidadConversion: _cantidadConversion!, tipoMoneda: nuevaDivisa);

        conversorModel.convertirDivisas();
        //Redirigir a la página de ajustes
        GoRouter.of(context).go('/settings');
      },
      child: const Text("Si"),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Deseas cambiar la divisa?"),
          content: Text('Divisa Elegida: $nuevaDivisa',
              style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }
}

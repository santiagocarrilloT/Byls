import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/controllers/transferencia_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransferAccounts extends StatefulWidget {
  const TransferAccounts({super.key});

  @override
  State<TransferAccounts> createState() => _TransferAccountsState();
}

class _TransferAccountsState extends State<TransferAccounts> {
  final TransferenciaController transferenciaController =
      TransferenciaController();
  final CuentaController cuentaController = CuentaController();

  List<CuentaModel> cuentas = [];
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  DateTime selectedDate = DateTime.now(); // Fecha seleccionada

  double? saldoCuenta;
  int? selectedCuentaIdOrigen;
  int? selectedCuentaIdDestino;
  String? selectedTipoDivisa;

  @override
  void initState() {
    super.initState();
    fetchCuentas();
  }

  //Función para cargar saldo de la cuenta de origen
  Future<void> cargarSaldoCuenta(int selectedCuentaIdOrigen) async {
    final cuentaSeleccionada = cuentas
        .firstWhere((cuenta) => cuenta.idCuenta == selectedCuentaIdOrigen);
    setState(() {
      saldoCuenta = cuentaSeleccionada.saldo;
    });
  }

  // Función para obtener las cuentas del usuario
  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        selectedCuentaIdOrigen = cuentas[0].idCuenta;
        selectedCuentaIdDestino = cuentas[0].idCuenta;
        selectedTipoDivisa = cuentas[0].tipoMoneda;
        cargarSaldoCuenta(selectedCuentaIdOrigen!);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: const Color(0xFF63F77D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pushReplacement('/app_entry', extra: 2);
          },
        ),
        title: const Text('Transferir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 7),

            // Saldo de la cuenta de Origen
            Text(
              saldoCuenta! <= 0
                  ? 'Saldo Insuficiente'
                  : 'Saldo Máximo: \$ ${saldoCuenta ?? 0} $selectedTipoDivisa',
              style: const TextStyle(
                color: Color(0xFF63F77D),
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            // Cuenta de Origen
            DropdownButtonFormField(
              value: selectedCuentaIdOrigen,
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
                  selectedCuentaIdOrigen = newValue;
                  cargarSaldoCuenta(selectedCuentaIdOrigen!);
                });
              },
              decoration: InputDecoration(
                labelText: 'Desde:',
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
                prefixIcon: const Icon(
                  Icons.send,
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

            const SizedBox(height: 20),

            // Campo para ingresar la cantidad
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Cantidad $selectedTipoDivisa',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00BFA5)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cuenta de Destino
            DropdownButtonFormField(
              value: selectedCuentaIdDestino,
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
                  selectedCuentaIdDestino = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Para: ',
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
                prefixIcon: const Icon(
                  Icons.download,
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

            const SizedBox(height: 20),

            // Selector de fecha
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF63F77D),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Seleccionar fecha'),
                ),
              ],
            ),

            const SizedBox(height: 20),

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

            // Botón para realizar la transferencia
            ElevatedButton(
              onPressed: () async {
                if (_cantidadController.text.isEmpty ||
                    _descripcionController.text.isEmpty) {
                  // Mostrar mensaje de error al insertar una transferencia
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, llena todos los campos',
                        style: TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.yellow,
                    ),
                  );
                  return;
                } else {
                  final cantidad = double.parse(_cantidadController.text);

                  final cuentaOrigen = cuentas
                      .firstWhere(
                          (cuenta) => cuenta.idCuenta == selectedCuentaIdOrigen)
                      .idCuenta;

                  final cuentaDestino = cuentas
                      .firstWhere((cuenta) =>
                          cuenta.idCuenta == selectedCuentaIdDestino)
                      .idCuenta;

                  // Saldo de la cuenta Origen seleccionada
                  double saldoOrigen = (cuentas
                          .firstWhere((element) =>
                              element.idCuenta == selectedCuentaIdOrigen)
                          .saldo)
                      .toDouble();

                  // Saldo de la cuenta Origen seleccionada
                  double saldoDestino = (cuentas
                          .firstWhere((element) =>
                              element.idCuenta == selectedCuentaIdDestino)
                          .saldo)
                      .toDouble();

                  try {
                    if (cuentaOrigen != cuentaDestino &&
                        cantidad > 0 &&
                        saldoOrigen >= cantidad) {
                      await transferenciaController.insertarTransferencia(
                        cuentaOrigen.toString(),
                        cuentaDestino.toString(),
                        cantidad,
                        _descripcionController.text,
                        selectedDate,
                      );

                      //Aumentar el saldo de la cuenta destino
                      cuentaController.actualizarSaldo(
                          saldoDestino,
                          cuentaDestino.toString(),
                          double.parse(_cantidadController.text),
                          true);

                      //Disminuir el saldo de la cuenta origen
                      cuentaController.actualizarSaldo(
                          saldoOrigen,
                          cuentaOrigen.toString(),
                          double.parse(_cantidadController.text),
                          false);

                      // Mostrar mensaje de error al insertar una transferencia
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transferencia realizada con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // Mostrar mensaje de error al insertar una transferencia
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Revise las cuentas seleccionadas y el monto a transferir',
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Colors.yellow,
                        ),
                      );
                      return;
                    }

                    context.go('/app_entry', extra: 2);
                  } catch (e) {
                    // Mostrar mensaje de error al insertar una transferencia
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se logró realizar la transferencia'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Transferir'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/icon_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class NewAccountMoney extends StatefulWidget {
  final CuentaModel? cuenta;
  const NewAccountMoney({super.key, this.cuenta});

  @override
  State<NewAccountMoney> createState() => _NewAccountMoneyState(cuenta: cuenta);
}

class _NewAccountMoneyState extends State<NewAccountMoney> {
  //Instancia de la clase CuentaController
  CuentaController cuentaController = CuentaController();
  //var icono;
  String? selectedCategory;

//Controladores para los campos de texto
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  //Constructor de la clase CuentaModel
  late CuentaModel? cuenta;
  _NewAccountMoneyState({this.cuenta});

  @override
  void initState() {
    super.initState();
    //cuenta = Provider.of<CuentaModel>(context, listen: false);
    if (cuenta != null) {
      selectedCategory = cuenta!.icono;
      _cantidadController.text = cuenta!.saldo.toString();
      _nombreController.text = cuenta!.nombreCuenta;
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const categories = IconsByls.colecctionIcons;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/app_entry');
          },
          color: Colors.white,
        ),
        title: Text(cuenta == null ? 'Crear cuenta' : 'Editar cuenta',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF044454),
        actions: [
          //Boton para eliminar cuenta si esta en modo edición
          if (cuenta != null)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                showValidateOTP(context, cuenta!.nombreCuenta,
                    cuenta!.idCuenta.toString(), cuentaController);
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
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _nombreController,
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la cuenta',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit, color: Color(0xFF00BFA5)),
                    filled: true,
                    fillColor: const Color(0xFF044454),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                    prefixIcon: Icon(Icons.attach_money, color: Color(0xFF00BFA5)),
                    filled: true,
                    fillColor: const Color(0xFF044454),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 400,
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          category['nombre'].toString() == selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory =
                                IconsByls.colecctionIcons[index]['nombre'];
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
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    context.go('/app_entry', extra: 2);
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          if (cuenta == null) {
                            cuentaController.createCuenta(
                              double.parse(_cantidadController.text),
                              _nombreController.text,
                              selectedCategory!,
                              'COP',
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Cuenta creada'),
                              backgroundColor: Colors.green,
                            ));
                          } else {
                            cuentaController.updateCuenta(
                              double.parse(_cantidadController.text),
                              _nombreController.text,
                              selectedCategory!,
                              'COP',
                              cuenta!.idCuenta.toString(),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Cuenta actualizada'),
                              backgroundColor: Colors.green,
                            ));
                          }

                          GoRouter.of(context).go('/app_entry');
                        } catch (e) {
                          //Mens
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(cuenta == null
                                  ? 'Error al crear cuenta'
                                  : 'Error al actualizar cuenta'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFF044454),
                        ),
                      ),
                      child: //Icon(icono),
                          Text(
                        cuenta == null ? 'Crear cuenta' : 'Actualizar cuenta',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )),
    );
  }
}

showValidateOTP(BuildContext context, String nombreCuenta, String idCuenta,
    CuentaController cuenta) {
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
      "Cancelar",
      style: TextStyle(color: Colors.black),
    ),
  );

  Widget continueButton = ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
          const Color.fromARGB(255, 126, 19, 11)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    onPressed: () async {
      try {
        print(idCuenta);
        cuenta.deleteCuenta(idCuenta);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta eliminada'),
            backgroundColor: Color(0xFFFF8A65),
          ),
        );
        GoRouter.of(context).go('/app_entry');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar cuenta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    child: const Text(
      "Eliminar",
      style: TextStyle(color: Colors.white),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("¿Deseas eliminar $nombreCuenta?"),
        backgroundColor: const Color(0xFFFF8A65),
        actions: [
          cancelButton,
          continueButton,
        ],
      );
    },
  );
}

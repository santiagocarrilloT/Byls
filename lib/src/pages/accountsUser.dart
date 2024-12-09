import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/cuenta_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/icon_model.dart';
import 'package:byls_app/src/pages/optionsSettings.dart';
import 'package:byls_app/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AccountsUser extends StatefulWidget {
  const AccountsUser({super.key});

  @override
  State<AccountsUser> createState() => _AccountsUserState();
}

class _AccountsUserState extends State<AccountsUser> {
  CuentaController cuentaController = CuentaController();
  List<CuentaModel> futureCuenta = [];
  FormatoUtils formatoUtils = FormatoUtils();

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
        futureCuenta = cuentasUsuario;
      });
    } catch (e) {
      print('Error fetching cuentas: $e');
    }
  }

//Función para obtener el saldo total de las cuentas
  double getSaldoTotal(double suma, int index) {
    if (index == futureCuenta.length) {
      return suma;
    } else {
      return getSaldoTotal(suma + futureCuenta[index].saldo, index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    var saldo = getSaldoTotal(0.0, 0);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF044454),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.02,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    Opciones.habilitarPuntuacion
                        ? 'Saldo total\n\$ ${formatoUtils.formatNumber(saldo)}'
                        : 'Saldo total\n\$ $saldo',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 17.5),

                //Botones de transferir y historial
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.go('/transferenciaCuentas');
                          },       
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04242C),
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            color: Color(0xFF00BFA5),
                          ),
                        ),
                        const Text(
                          'Transferir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 80.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04242C),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: Color(0xFF00BFA5),
                          ),
                        ),
                        const Text(
                          'Historial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.26,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF04242C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: futureCuenta.length,
                      itemBuilder: (BuildContext context, int index) {
                        var icono;
                        if (futureCuenta[index].icono != null) {
                          icono = IconsByls.colecctionIcons.firstWhere(
                              (element) =>
                                  element['nombre'] ==
                                  futureCuenta[index].icono)['icono'];
                        } else {
                          icono = Icons.account_balance_wallet;
                        }

                        //Margen y decoración de la lista
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(155, 255, 255, 255),
                            border: Border.all(color: const Color(0xFF006064)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(
                              futureCuenta[index].nombreCuenta,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            leading: Hero(
                              tag: index,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(icono, color: Colors.black),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  Opciones.habilitarPuntuacion
                                      ? '\$ ${formatoUtils.formatNumber(futureCuenta[index].saldo)}'
                                      : '\$ ${futureCuenta[index].saldo}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                )
                              ],
                            ),
                            onTap: () {
                              context.go(
                                '/nuevaCuenta',
                                extra: futureCuenta[index],
                              );
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
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/reporte');
        },
        child: const Icon(
          Icons.add_a_photo,
        ),
      ), */
    );
  }
}

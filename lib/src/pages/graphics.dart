import 'package:byls_app/controllers/Transaccion_provider.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/categorias_usuario.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/src/pages/optionsSettings.dart';
import 'package:byls_app/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Clase de Categoría
class Categoria {
  final String nombre;
  final IconData icono;
  final Color color;

  Categoria({required this.nombre, required this.icono, required this.color});
}

class GraphicsView extends StatefulWidget {
  const GraphicsView({super.key});

  @override
  State<GraphicsView> createState() => _GraphicsViewState();
}

class _GraphicsViewState extends State<GraphicsView> {
  // Controla si mostramos ingresos (True) o egresos (False)
  bool transaccionElegida = true;
  String selectedType = 'Ingreso';
  IngresosController ingresosController = IngresosController();
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;
  Map<String, String> categoriasUsuariosColor = {};
  Map<String, String> categoriasUsuariosIcono = {};
  FormatoUtils formatoUtils = FormatoUtils();

  //Lista de Transacciones
  List<IncomeModel> futureIngresos = [];

  @override
  void initState() {
    super.initState();
    fetchCuentas();
    fetchColor();
    fetchNombre();
  }

  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        //Opciones para seleccionar la cuenta por defecto
        if (Opciones.selectedCuentaId == 0 ||
            Opciones.selectedCuentaId == null) {
          selectedCuentaId = cuentas[0].idCuenta;
        } else {
          selectedCuentaId = Opciones.selectedCuentaId;
        }
        //selectedCuentaId = cuentas[0].idCuenta;
        fetchTransacciones(
            selectedCuentaId!); // Llama traer los ingresos de esa cuenta
      }
    });
  }

  // Método para obtener los ingresos a partir del idCuenta seleccionado
  void fetchTransacciones(int idCuenta) async {
    try {
      List<IncomeModel> transacciones =
          await IncomeModel.getTransacciones(idCuenta);

      setState(() {
        futureIngresos = transacciones;
        Map<Categoria, double> result = {};
        for (var entry in futureIngresos) {
          Categoria? categoria = categoriasIngreso.firstWhere(
            (cat) => cat.nombre == entry.nombreCategoria,
            orElse: () => Categoria(
                nombre: entry.nombreCategoria ?? 'Unknown',
                icono: Icons.help,
                color: Colors.grey),
          );
          result[categoria] = entry.montoTransaccion;
        }
      });
    } catch (e) {
      print('Error fetching transacciones: $e');
    }
  }

  Future<void> fetchColor() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final categoriasUsuario =
        await CategoriasusuarioModel.getCategoriasNombre(userId!);
    setState(() {
      categoriasUsuariosColor = categoriasUsuario;
    });
  }

  Future<void> fetchNombre() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final categoriasUsuario =
        await CategoriasusuarioModel.getCategoriasIcono(userId!);
    setState(() {
      categoriasUsuariosIcono = categoriasUsuario;
    });
  }

  // Función para conocer los colores de las categorías
  Categoria getIcon(String nombreCategoria) {
    // Obtener el nombre del icono original de la categoría
    var iconoOriginal = categoriasUsuariosIcono[nombreCategoria];

    // Si la categoría del usuario contiene el icono original, entonces se devuelve la categoría con el icono original

    switch (selectedType == 'Ingreso') {
      case true:
        return categoriasIngreso.firstWhere(
          (element) => element.nombre == iconoOriginal,
        );
      case false:
        return categoriasGasto
            .firstWhere((element) => element.nombre == iconoOriginal);
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
        backgroundColor: const Color(0xFF044454),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/app_entry', extra: 1);
          },
        ),
        title: const Text(
          'Transacciones por Cuenta',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        /*title:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: selectedCuentaId,
              icon: const Icon(Icons.arrow_downward, color: Color(0xFF006064)),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Color(0xFF006064)),
              dropdownColor: const Color(0xFF00BFA5),
              underline: Container(
                height: 2,
                color: const Color(0xFF006064),
              ),
              onChanged: (int? newValue) {
                setState(
                  () {
                    selectedCuentaId = newValue;
                    fetchTransacciones(selectedCuentaId!);
                  },
                );
              },
              items: cuentas.map<DropdownMenuItem<int>>((CuentaModel cuenta) {
                return DropdownMenuItem<int>(
                  value: cuenta.idCuenta,
                  child: Text(
                    cuenta.nombreCuenta,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ],
        ), */
      ),
      backgroundColor: const Color(0xFF04242C),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButton(
                value: selectedCuentaId,
                icon: const Icon(Icons.arrow_downward,
                    color: Color.fromARGB(255, 253, 253, 253)),
                iconSize: 24,
                elevation: 16,
                style:
                    const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                dropdownColor: const Color(0xFF044454),
                underline: Container(
                  height: 2,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                onChanged: (int? newValue) {
                  setState(
                    () {
                      selectedCuentaId = newValue;
                      fetchTransacciones(selectedCuentaId!);
                    },
                  );
                },
                items: cuentas.map<DropdownMenuItem<int>>((CuentaModel cuenta) {
                  return DropdownMenuItem<int>(
                    value: cuenta.idCuenta,
                    child: Text(
                      cuenta.nombreCuenta,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: transaccionElegida
                        ? const Color(0xFF044454)
                        : Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            20.0), // Redondea la esquina superior derecha
                        bottomLeft: Radius.circular(20.0),
                      ), // Sin bordes redondeados
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      transaccionElegida = true;
                      selectedType = 'Ingreso';
                    });
                  },
                  child: Text('Ingresos',
                      style: TextStyle(
                        color: transaccionElegida ? Colors.white : Colors.black,
                      )),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: transaccionElegida
                        ? Colors.white
                        : const Color(0xFF044454),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                            20.0), // Redondea la esquina superior derecha
                        bottomRight: Radius.circular(20.0),
                      ), // Sin bordes redondeados
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      transaccionElegida = false;
                      selectedType = 'Gasto';
                    });
                  },
                  child: Text('Egresos',
                      style: TextStyle(
                        color: transaccionElegida ? Colors.black : Colors.white,
                      )),
                ),
              ),
            ],
          ),
          filteredTransacciones.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 10.0),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: transaccionElegida
                        ? _buildPieChart(filteredTransacciones)
                        : _buildPieChart(filteredTransacciones),
                  ),
                ),
          filteredTransacciones.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 10.0),
                  child: const Text(
                    'No hay transacciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredTransacciones.length,
                    itemBuilder: (BuildContext context, int index) {
                      var color = getColor(filteredTransacciones[index]
                          .nombreCategoria
                          .toString());
                      var icono;
                      selectedType == 'Gasto'
                          ? icono = categoriasGasto
                              .firstWhere(
                                (element) =>
                                    element.nombre ==
                                    filteredTransacciones[index]
                                        .nombreCategoria,
                                orElse: () => getIcon(
                                    filteredTransacciones[index]
                                            .nombreCategoria ??
                                        ''),
                              )
                              .icono
                          : icono = categoriasIngreso
                              .firstWhere(
                                (element) =>
                                    element.nombre ==
                                    filteredTransacciones[index]
                                        .nombreCategoria,
                                orElse: () => getIcon(
                                    filteredTransacciones[index]
                                            .nombreCategoria ??
                                        ''),
                              )
                              .icono;
                      icono ??= Icons.abc;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                              color: const Color.fromARGB(255, 198, 201, 201)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            '${filteredTransacciones[index].nombreCategoria}',
                            style: const TextStyle(color: Color(0xFFFFFFFF)),
                          ),
                          leading: Hero(
                            tag: index,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                icono,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Opciones.habilitarPuntuacion
                                    ? formatoUtils.formatNumber(
                                        filteredTransacciones[index]
                                            .montoTransaccion)
                                    : '\$ ${filteredTransacciones[index].montoTransaccion}',
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
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
    );
  }

  // Función para construir una gráfica dinámica basada en los valores de la categoría
  Widget _buildPieChart(List<IncomeModel> data) {
    return PieChart(
      PieChartData(
        sections: data.map((datosCuentas) {
          return PieChartSectionData(
            color: getColor(datosCuentas.nombreCategoria.toString()),
            titleStyle: const TextStyle(color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  // Función para conocer los colores de las categorías
  Color getColor(String nombreCategoria) {
    if (categoriasUsuariosColor.containsKey(nombreCategoria)) {
      return Color(int.parse(categoriasUsuariosColor[nombreCategoria]!));
    } else {
      switch (transaccionElegida) {
        case true:
          return categoriasIngreso
              .firstWhere(
                (element) => element.nombre == nombreCategoria,
              )
              .color;
        case false:
          return categoriasGasto
              .firstWhere((element) => element.nombre == nombreCategoria)
              .color;
      }
    }
  }
}

final List<Categoria> categoriasGasto = [
  Categoria(
      nombre: 'Casa',
      icono: Icons.home,
      color: const Color.fromARGB(255, 127, 54, 244)),
  Categoria(nombre: 'Educación', icono: Icons.school, color: Colors.green),
  Categoria(
      nombre: 'Gasolina', icono: Icons.local_gas_station, color: Colors.red),
  Categoria(nombre: 'Moto', icono: Icons.motorcycle, color: Colors.purple),
  Categoria(
      nombre: 'Teléfono', icono: Icons.phone_android, color: Colors.orange),
  Categoria(nombre: 'Alimentación', icono: Icons.fastfood, color: Colors.brown),
  Categoria(nombre: 'TV', icono: Icons.movie, color: Colors.pink),
  Categoria(
      nombre: 'Salud', icono: Icons.local_hospital, color: Colors.blueAccent),
  Categoria(nombre: 'Ropa', icono: Icons.checkroom, color: Colors.amber),
  Categoria(
      nombre: 'Viajes',
      icono: Icons.airplanemode_active,
      color: Colors.lightBlue),
  Categoria(
      nombre: 'Suscripciones',
      icono: Icons.subscriptions,
      color: Colors.deepPurple),
  Categoria(
      nombre: 'Transporte',
      icono: Icons.directions_bus,
      color: Colors.purpleAccent),
  Categoria(nombre: 'house', icono: Icons.home, color: Colors.grey),
  Categoria(nombre: 'school', icono: Icons.school, color: Colors.grey),
  Categoria(nombre: 'fastfood', icono: Icons.fastfood, color: Colors.grey),
  Categoria(
      nombre: 'local_gas_station',
      icono: Icons.local_gas_station,
      color: Colors.grey),
  Categoria(
      nombre: 'phone_android', icono: Icons.phone_android, color: Colors.grey),
  Categoria(
      nombre: 'health_and_safety',
      icono: Icons.health_and_safety,
      color: Colors.grey),
  Categoria(
      nombre: 'shopping_cart', icono: Icons.shopping_cart, color: Colors.grey),
  Categoria(nombre: 'directions_car', icono: Icons.directions_car, color: Colors.grey),
  Categoria(nombre: 'hotel', icono: Icons.hotel, color: Colors.grey),
];

final List<Categoria> categoriasIngreso = [
  Categoria(nombre: 'Salario', icono: Icons.attach_money, color: Colors.teal),
  Categoria(nombre: 'Moto', icono: Icons.motorcycle, color: Colors.purple),
  Categoria(
      nombre: 'Gasolina', icono: Icons.local_gas_station, color: Colors.red),
  Categoria(
      nombre: 'Inversiones', icono: Icons.trending_up, color: Colors.orange),
  Categoria(nombre: 'Venta', icono: Icons.store, color: Colors.green),
  Categoria(nombre: 'Freelance', icono: Icons.work, color: Colors.indigo),
  Categoria(
      nombre: 'Regalos', icono: Icons.card_giftcard, color: Colors.redAccent),
  Categoria(nombre: 'Alquiler', icono: Icons.apartment, color: Colors.brown),
  Categoria(nombre: 'Bonificaciones', icono: Icons.star, color: Colors.yellow),
  Categoria(
      nombre: 'Intereses',
      icono: Icons.account_balance,
      color: Colors.tealAccent),
  Categoria(nombre: 'Dividendos', icono: Icons.paid, color: Colors.greenAccent),
  Categoria(
      nombre: 'attach_money', icono: Icons.attach_money, color: Colors.grey),
  Categoria(
      nombre: 'trending_up', icono: Icons.trending_up, color: Colors.grey),
  Categoria(
      nombre: 'monetization_on',
      icono: Icons.monetization_on,
      color: Colors.grey),
  Categoria(
      nombre: 'account_balance_wallet',
      icono: Icons.account_balance_wallet,
      color: Colors.grey),
  Categoria(nombre: 'phone_android', icono: Icons.business, color: Colors.grey),
  Categoria(
      nombre: 'health_and_safety',
      icono: Icons.health_and_safety,
      color: Colors.grey),
  Categoria(
      nombre: 'card_giftcard', icono: Icons.card_giftcard, color: Colors.grey),
  Categoria(nombre: 'store', icono: Icons.store, color: Colors.grey),
  Categoria(nombre: 'pie_chart', icono: Icons.pie_chart, color: Colors.grey),
  // Default
];

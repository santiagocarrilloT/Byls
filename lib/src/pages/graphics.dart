import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/categorias_usuario.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
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
];

class GraphicsView extends StatefulWidget {
  const GraphicsView({super.key});

  @override
  State<GraphicsView> createState() => _GraphicsViewState();
}

class _GraphicsViewState extends State<GraphicsView> {
  // Controla si mostramos ingresos (True) o egresos (False)
  bool transaccionElegida = true;
  IngresosController ingresosController = IngresosController();
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;
  Map<String, String> categoriasUsuarios = {};
  FormatoUtils formatoUtils = FormatoUtils();

  //Mostrar transacción (Ingresos)
  List<IncomeModel> futureIngresos = [];

  @override
  void initState() {
    super.initState();
    fetchCuentas();
    fetchColor();
  }

  Future<void> fetchCuentas() async {
    final authService = Provider.of<AuthController>(context, listen: false);
    final userId = authService.currentUser?.id;
    final cuentasUsuario = await CuentaModel.getCuentas(userId!);
    setState(() {
      cuentas = cuentasUsuario;
      if (cuentas.isNotEmpty) {
        selectedCuentaId = cuentas[0].idCuenta;
        fetchTransacciones(
            selectedCuentaId!); // Llama traer los ingresos de esa cuenta
      }
      print(formatoUtils.formatNumber(cuentas[1].saldo));
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
      categoriasUsuarios = categoriasUsuario;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar transacciones según el tipo seleccionado
    List<IncomeModel> filteredTransacciones = futureIngresos
        .where(
          (transaccion) =>
              transaccion.tipoTransaccion ==
              (transaccionElegida ? 'Ingreso' : 'Gasto'),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
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
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      transaccionElegida ? Colors.blue : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    transaccionElegida = true;
                  });
                },
                child: Text('Ingresos',
                    style: TextStyle(
                      color: transaccionElegida ? Colors.white : Colors.black,
                    )),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      transaccionElegida ? Colors.white : Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    transaccionElegida = false;
                  });
                },
                child: Text('Egresos',
                    style: TextStyle(
                      color: transaccionElegida ? Colors.black : Colors.white,
                    )),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: transaccionElegida
                  ? _buildPieChart(filteredTransacciones)
                  : _buildPieChart(filteredTransacciones),
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
    if (categoriasUsuarios.containsKey(nombreCategoria)) {
      return Color(int.parse(categoriasUsuarios[nombreCategoria]!));
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

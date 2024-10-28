import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

// Clase de Categoría
class Categoria {
  final String nombre;
  final IconData icono;
  final Color color;

  Categoria({required this.nombre, required this.icono, required this.color});
}

final List<Categoria> categoriasGasto = [
  Categoria(nombre: 'Casa', icono: Icons.home, color: const Color.fromARGB(255, 127, 54, 244)),
  Categoria(nombre: 'Educación', icono: Icons.school, color: Colors.green),
  Categoria(nombre: 'Gasolina', icono: Icons.local_gas_station, color: Colors.red),
  Categoria(nombre: 'Moto', icono: Icons.motorcycle, color: Colors.purple),
  Categoria(nombre: 'Teléfono', icono: Icons.phone_android, color: Colors.orange),
  Categoria(nombre: 'Alimentación', icono: Icons.fastfood, color: Colors.brown),
  Categoria(nombre: 'TV', icono: Icons.movie, color: Colors.pink),
  Categoria(nombre: 'Salud', icono: Icons.local_hospital, color: Colors.blueAccent),
  Categoria(nombre: 'Ropa', icono: Icons.checkroom, color: Colors.amber),
  Categoria(nombre: 'Viajes', icono: Icons.airplanemode_active, color: Colors.lightBlue),
  Categoria(nombre: 'Suscripciones', icono: Icons.subscriptions, color: Colors.deepPurple),
];

final List<Categoria> categoriasIngreso = [
  Categoria(nombre: 'Salario', icono: Icons.attach_money, color: Colors.teal),
  Categoria(nombre: 'Moto', icono: Icons.motorcycle, color: Colors.purple),
  Categoria(nombre: 'Gasolina', icono: Icons.local_gas_station, color: Colors.red),
  Categoria(nombre: 'Inversiones', icono: Icons.trending_up, color: Colors.orange),
  Categoria(nombre: 'Venta', icono: Icons.store, color: Colors.green),
  Categoria(nombre: 'Freelance', icono: Icons.work, color: Colors.indigo),
  Categoria(nombre: 'Regalos', icono: Icons.card_giftcard, color: Colors.redAccent),
  Categoria(nombre: 'Alquiler', icono: Icons.apartment, color: Colors.brown),
  Categoria(nombre: 'Bonificaciones', icono: Icons.star, color: Colors.yellow),
  Categoria(nombre: 'Intereses', icono: Icons.account_balance, color: Colors.tealAccent),
  Categoria(nombre: 'Dividendos', icono: Icons.paid, color: Colors.greenAccent),
];

class GraphicsView extends StatefulWidget {
  const GraphicsView({super.key});

  @override
  State<GraphicsView> createState() => _GraphicsViewState();
}

class _GraphicsViewState extends State<GraphicsView> {
  IngresosController ingresosController = IngresosController();
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;

  //Mostrar transacción (Ingresos)
  List<IncomeModel> futureIngresos = [];

  @override
  void initState() {
    super.initState();
    fetchCuentas();
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
    });
  }
Map<String, double> futureIngresos2 = {};

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
          orElse: () => Categoria(nombre: entry.nombreCategoria ?? 'Unknown', icono: Icons.help, color: Colors.grey));
      result[categoria] = entry.montoTransaccion;
    }
  });

      //Mostrar datos de la transacción
      /* print(futureIngresos[0].nombreCategoria);
      print(futureIngresos[0].montoTransaccion);
      print(futureIngresos[0].fechaTransaccion); */
    } catch (e) {
      print('Error fetching transacciones: $e');
    }
  }
  bool showIncome = true; // Controla si mostramos ingresos o egresos

  // Aquí es donde vamos a almacenar los valores monetarios para cada categoría
  Map<Categoria, double> valoresIngreso = {
    categoriasIngreso[0]: 5000,  // Salario
    categoriasIngreso[1]: 2000,  // Inversiones
    categoriasIngreso[2]: 1000,  // Venta
  };

  Map<Categoria, double> valoresGasto = {
    categoriasGasto[0]: 1500,  // Casa
    categoriasGasto[1]: 600,   // Educación
    categoriasGasto[2]: 300,   // Gasolina
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficas de Gestión de Gastos'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showIncome = true;
                  });
                },
                child: const Text('Ingresos'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showIncome = false;
                  });
                },
                child: const Text('Egresos'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: showIncome
                  ? _buildPieChart(futureIngresos)
                  : _buildPieChart(futureIngresos),
            ),
          ),
        ],
      ),
    );
  }

  // Función para convertir Map<String, double> a Map<Categoria, double>
 /* Map<Categoria, double> _convertToCategoriaMap(Map<String, double> data) {
    Map<Categoria, double> result = {};
    for (var entry in data.entries) {
      Categoria? categoria = categoriasIngreso.firstWhere(
          (cat) => cat.nombre == entry.key,
          orElse: () => Categoria(nombre: entry.key, icono: Icons.help, color: Colors.grey));
      result[categoria] = entry.value;
    }
    return result;
  } */

  // Función para construir una gráfica dinámica basada en los valores de la categoría
  Widget _buildPieChart(List<IncomeModel> data) {
    return PieChart(
      PieChartData(
        sections: data.map((entry) {
          return PieChartSectionData(
            color: Colors.blue,
            value: entry.montoTransaccion,
            title: entry.nombreCategoria,
            titleStyle: const TextStyle(color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}

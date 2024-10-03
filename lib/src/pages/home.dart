import 'package:byls_app/controllers/Transaccion_provider.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:byls_app/models/user_model.dart';
import 'package:byls_app/src/pages/transaccion.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  IngresosController ingresosController = IngresosController();
  List<CuentaModel> cuentas = [];
  int? selectedCuentaId;
  final List<bool> _selections =
      List.generate(5, (_) => false); // Para los seleccionables

  //Mostrar transacción (Ingresos)
  List<IncomeModel> futureIngresos = [];

  @override
  void initState() {
    super.initState();
    fetchCuentas();
  }

  // Método para obtener las cuentas del usuario logueado
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

  // Método para obtener los ingresos a partir del idCuenta seleccionado
  void fetchTransacciones(int idCuenta) async {
    try {
      List<IncomeModel> transacciones =
          await IncomeModel.getTransacciones(idCuenta);

      setState(() {
        futureIngresos = transacciones;
      });

      //Mostrar datos de la transacción
      /* print(futureIngresos[0].nombreCategoria);
      print(futureIngresos[0].montoTransaccion);
      print(futureIngresos[0].fechaTransaccion); */
    } catch (e) {
      print('Error fetching transacciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        backgroundColor: const Color.fromARGB(230, 91, 255, 173),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'Home');
          },
        ),
        title: const Text("Home"),
        actions: const [],
        //Línea resaltada
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Altura de la línea
          child: Container(
            color: Colors.black, // Color de la línea resaltada
            height: 1.0, // Altura de la línea
          ),
        ),
      ), */
      body: Stack(
        children: [
          // Fondo de color
          Container(
            color: const Color.fromARGB(230, 91, 255, 173),
          ),
          TextButton(
            onPressed: () {
              // Acción al presionar el botón
              context.go('/nuevaCuenta', extra: null);
            },
            child: const Text('Nueva Cuenta'),
          ),
          // Parte superior con el borde redondeado
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF006064),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Center(
                // Textos "Gastos" e "Ingreso"
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceAround, // Para que los textos queden separados
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Acción cuando se toque "Gastos"
                            print("Gastos seleccionado");
                          },
                          child: const Text(
                            'Gastos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Acción cuando se toque "Ingreso"
                            print("Ingreso seleccionado");
                          },
                          child: const Text(
                            'Ingreso',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Lista de transacciones
                    Expanded(
                      child: ListView.builder(
                        itemCount: futureIngresos.length,
                        //itemCount: _images.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            // Margen y decoración de la lista
                            margin: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              border: Border.all(
                                color: const Color(0xFF00BFA5),
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Bordes redondeados
                            ),
                            // Elementos de la lista
                            child: ListTile(
                              title: Text(
                                '${futureIngresos[index].nombreCategoria}',
                                style:
                                    const TextStyle(color: Color(0xFF4E4E4E)),
                              ),
                              leading: Hero(
                                tag: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.house,
                                    color: Color(0xFF4E4E4E),
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$ ${futureIngresos[index].montoTransaccion}',
                                    style: const TextStyle(
                                      color: Color(0xFF4E4E4E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      // Acción al presionar el icono de basura
                                      try {
                                        await ingresosController.deleteIngreso(
                                            futureIngresos[index]
                                                .idTransaccion
                                                .toString());
                                        setState(() {
                                          futureIngresos.removeAt(
                                              index); // Eliminar el elemento de la lista
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Transacción eliminada correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        context.go('/app_entry');
                                      } catch (e) {
                                        //Recargar la página

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Error al eliminar transacción'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                final transaccionProvider =
                                    Provider.of<TransaccionProvider>(context,
                                        listen: false);
                                transaccionProvider.setCurrentTransaccion(
                                    futureIngresos[index]);
                                context.go('/transaccionEdit',
                                    extra: futureIngresos[index]);
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
          ),
          // Cuadro centrado con seleccionables
          /* Positioned(
            top: MediaQuery.of(context).size.height *
                0.25, // Ajuste para centrarlo
            left: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20), // Bordes semi-redondeados
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Seleccionar periodo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  /* ToggleButtons(
                    borderRadius: BorderRadius.circular(10),
                    isSelected: _selections,
                    children: const [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Día')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Semana')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Mes')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Año')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Periodo')),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _selections.length; i++) {
                          _selections[i] = i == index;
                        }
                      });
                    },
                  ), */
                ],
              ),
            ),
          ),
        */
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón
          context.go('/transaccion');
        },
        backgroundColor: const Color(0xFFFF6F61),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/* const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.account_balance_wallet_outlined),
    activeIcon: Icon(Icons.account_balance_wallet),
    label: 'Inicio',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.analytics_outlined),
    activeIcon: Icon(Icons.analytics),
    label: 'Gráficos',
  ),
  BottomNavigationBarItem(
    icon: SizedBox.shrink(), // Espacio vacío para el botón central
    label: '',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.document_scanner_outlined),
    activeIcon: Icon(Icons.document_scanner_rounded),
    label: 'Informe',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline_rounded),
    activeIcon: Icon(Icons.person_rounded),
    label: 'Perfil',
  ),
]; */

class SecondPage extends StatelessWidget {
  final int heroTag;
  const SecondPage({required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hero ListView Page 2")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: heroTag,
                child: Image.network(_images[heroTag]),
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Content goes here",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          )
        ],
      ),
    );
  }
}

final List<String> _images = [
  'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  'https://images.pexels.com/photos/2662116/pexels-photo-2662116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/273935/pexels-photo-273935.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/1591373/pexels-photo-1591373.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/462024/pexels-photo-462024.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/325185/pexels-photo-325185.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'
];

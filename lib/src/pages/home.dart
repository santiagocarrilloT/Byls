import 'package:byls_app/router/routes.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:byls_app/src/pages/transaccion.dart';
import 'package:flutter/material.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<bool> _selections =
      List.generate(5, (_) => false); // Para los seleccionables

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'Home');
          },
        ),
        title: const Text("Home"),
        actions: const [
          /* IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthController>().signOutCt();
              context.go('/signIn');
            },
          ), */
        ],
        //Línea resaltada
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Altura de la línea
          child: Container(
            color: Colors.black, // Color de la línea resaltada
            height: 1.0, // Altura de la línea
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo de color
          Container(
            color: const Color(0xFF26A69A),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Selected Page: ${_navBarItems[_selectedIndex].label}",
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // Textos "Gastos" e "Ingreso"
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.20, // Un poco más abajo de la división
            left: 0,
            right: 0,
            child: Row(
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
          ),
          // Cuadro centrado con seleccionables
          Positioned(
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
                  ToggleButtons(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón
          print("Agregar nuevo elemento");
          context.go('/transaccion');
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

const _navBarItems = [
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
];

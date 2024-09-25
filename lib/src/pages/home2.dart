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
  List<bool> _selections = List.generate(5, (_) => false); // Para los seleccionables

  // Datos de ejemplo para las categorías de ingresos
  final List<Map<String, dynamic>> ingresos = [
    {'icono': Icons.business_center, 'categoria': 'Salario', 'monto': 1200000},
    {'icono': Icons.card_giftcard, 'categoria': 'Regalos', 'monto': 300000},
    {'icono': Icons.account_balance, 'categoria': 'Inversiones', 'monto': 450000},
    {'icono': Icons.attach_money, 'categoria': 'Freelance', 'monto': 200000},
    {'icono': Icons.business_center, 'categoria': 'Salario', 'monto': 1200000},
    {'icono': Icons.card_giftcard, 'categoria': 'Regalos', 'monto': 300000},
    {'icono': Icons.account_balance, 'categoria': 'Inversiones', 'monto': 450000},
    {'icono': Icons.attach_money, 'categoria': 'Freelance', 'monto': 200000},
    // Puedes añadir más categorías aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Texto "Seleccionar periodo"
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
                    const SizedBox(height: 20),
                    
                    // Selector entre "Ingresos" y "Gastos"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                'Ingresos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                                ),
                              ),
                              if (_selectedIndex == 0)
                                Container(
                                  width: 60,
                                  height: 2,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                'Gastos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                                ),
                              ),
                              if (_selectedIndex == 1)
                                Container(
                                  width: 60,
                                  height: 2,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Divider entre secciones
                    const Divider(color: Colors.black),
                    const SizedBox(height: 10),
                    
                    // Lista de ingresos o gastos (expandida y scrollable)
                    Expanded(
                      child: ListView.builder(
                        itemCount: ingresos.length,
                        itemBuilder: (context, index) {
                          final ingreso = ingresos[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00796B),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Icon(ingreso['icono'], color: Colors.white),
                              title: Text(
                                ingreso['categoria'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                "${ingreso['monto']} COL\$",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, 
                                vertical: 10.0,
                              ),
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

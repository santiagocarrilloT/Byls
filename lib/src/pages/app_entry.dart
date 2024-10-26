import 'package:byls_app/src/pages/accountsUser.dart';
import 'package:byls_app/src/pages/graphics.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';

class NavigationClass extends StatefulWidget {
  final int? seleccionarVentana;
  const NavigationClass({super.key, this.seleccionarVentana});

  @override
  State<NavigationClass> createState() =>
      _NavigationClassState(seleccionarVentana: seleccionarVentana);
}

class _NavigationClassState extends State<NavigationClass> {
  int _selectedIndex = 0;
  int? seleccionarVentana;
  _NavigationClassState({this.seleccionarVentana}) {
    if (seleccionarVentana != null) {
      _selectedIndex = seleccionarVentana!;
      seleccionarVentana = null;
    }
  }
  BottomNavigationBarType _bottomNavType = BottomNavigationBarType.fixed;

  static final List<Widget> _pages = <Widget>[
    const Home(),
    const Graphics_View(),
    const AccountsUser(), // Pantalla de inicio
    const ProfileView(), // Pantalla de perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(230, 255, 255, 255),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        type: _bottomNavType,
        onTap: (index) {
          setState(() {
            if (seleccionarVentana != null) {
              _selectedIndex = seleccionarVentana!;
            } else {
              _selectedIndex = index;
            }
          });
        },
        items: _navBarItems,
      ),
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
  /* BottomNavigationBarItem(
    icon: SizedBox.shrink(), // Espacio vacío para el botón central
    label: '',
  ), */
  BottomNavigationBarItem(
    icon: Icon(Icons.document_scanner_outlined),
    activeIcon: Icon(Icons.document_scanner_rounded),
    label: 'Cuentas',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline_rounded),
    activeIcon: Icon(Icons.person_rounded),
    label: 'Perfil',
  ),
];

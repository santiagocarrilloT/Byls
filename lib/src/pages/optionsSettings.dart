import 'package:byls_app/models/cuenta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class Opciones extends StatefulWidget {
  const Opciones({super.key});

  @override
  State<Opciones> createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF63F77D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pushReplacement('/app_entry', extra: 3);
          },
        ),
        title: const Text('Ajustes'),
      ),
      body: Container(
        color: const Color(0xFF124C2D),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ListTile(
              title: const Text(
                'Cambiar Divisas',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.currency_exchange_outlined,
                color: Colors.white,
              ),
              onTap: () => {
                context.go('/cambiarDivisas'),
              },
            ),
            ListTile(
              title: const Text(
                'Tema oscuro',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.dark_mode,
                color: Colors.white,
              ),
              onTap: () => {},
              /* trailing: Switch(
          value: false,
          onChanged: (value) {},
        ), */
            ),
          ],
        ),
      ),
    );
  }
}

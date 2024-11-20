import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class Opciones extends StatefulWidget {
  static bool habilitarPuntuacion = false;
  const Opciones({super.key});

  @override
  State<Opciones> createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pushReplacement('/app_entry', extra: 3);
          },
        ),
        title: const Text('Ajustes'),
      ),
      body: Container(
        color: const Color(0xFF006064),
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
                'Cuenta Inicial',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.star,
                color: Colors.white,
              ),
              onTap: () => {},
            ),
            ListTile(
              title: const Text(
                'Habilitar Puntuación a Saldos',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.remove_red_eye,
                color: Colors.white,
              ),
              trailing: Switch(
                activeColor: const Color(0xFFFF8A65),
                value: Opciones.habilitarPuntuacion,
                onChanged: (value) {
                  setState(() {
                    Opciones.habilitarPuntuacion = value;
                  });
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Puntuación a saldos habilitada'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Puntuación a saldos deshabilitada'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

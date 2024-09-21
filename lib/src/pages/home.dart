import 'package:byls_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  /* @override
  void initState() {
    super.initState();
    // Inicializa authController aquí
    authController = AuthController();
  }
 */
  int contador = 0;
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(96, 5, 192, 161),
      appBar: AppBar(
        title: const Text("data"),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
        actions: [
          TextButton(
            style: TextButton.styleFrom(iconColor: Colors.white),
            onPressed: () {
              authController.signOutCt();
              Navigator.pushNamed(context, "SignIn");
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Contador: $contador",
          style: const TextStyle(fontSize: 25),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          increment();
        },
      ),
    );
  }

  void increment() {
    setState(() {
      contador++;
    });
  }
}

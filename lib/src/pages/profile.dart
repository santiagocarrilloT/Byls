import 'package:byls_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserModel? usuarioDatos;

  @override
  void initState() {
    super.initState();
    // Llamamos a la función para obtener los datos del usuario al iniciar la vista
    _getUsuarioActual();
  }

  // Función para obtener los datos del usuario
  Future<void> _getUsuarioActual() async {
    UserModel? usuario = await UserModel.getUsuarioActual();

    // Actualizamos el estado con los datos del usuario
    setState(() {
      usuarioDatos = usuario;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(230, 91, 255, 173),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 35),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 60, color: Color(0xFF000000)),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    usuarioDatos?.email ?? "",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 125, 124, 221),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text(
                      "Ajustes",
                      style: TextStyle(
                          color: Colors.white), // Cambiar color del texto
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: Colors.white),
                    title: const Text(
                      "Cambiar contraseña",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      context.go('/newPass');
                    },
                  ),
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.receipt,
                        color: Colors.white),
                    title: const Text(
                      "Privacidad",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.logout_outlined, color: Colors.white),
                    title: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      authController.signOutCt();
                      context.go('/signIn');
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

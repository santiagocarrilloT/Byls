import 'package:byls_app/models/user_model.dart';
import 'package:byls_app/src/pages/optionsSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
      child: Scaffold(
        backgroundColor: const Color(0xFF044454), // Cambia el color de fondo aquí
        body: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 20, top: 35),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 60, color: Colors.white),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      usuarioDatos?.email ?? "",
                      style: const TextStyle(
                        color: Colors.white,
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
                  color: Color(0xFF04242C),
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
                      onTap: () {
                        context.go('/settings');
                      },
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
                      onTap: () async {
                      await Opciones.removeValue();
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
    ),
  );
  }
}

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
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: const Color(0xFF00BFA5),
            child: const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 35),
              child: Row(
                children: [
                  Icon(Icons.person, size: 70, color: Color(0xFF000000)),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    "data",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF006064),
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

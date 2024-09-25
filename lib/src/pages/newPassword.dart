import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class NewPassword extends StatefulWidget {
  //final String id;
  const NewPassword({
    super.key,
    /*required this.id*/
  });

  @override
  // ignore: library_private_types_in_public_api
  _NewPassState createState() => _NewPassState();
}

class _NewPassState extends State<NewPassword> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Fondo(),
          Contenido(),
        ],
      ),
    );
  }
}

class Contenido extends StatefulWidget {
  const Contenido({super.key});

  @override
  State<Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<Contenido> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Logobyls(),
          SizedBox(
            height: 30,
          ),
          Datos(),
        ],
      ),
    );
  }
}

class Logobyls extends StatelessWidget {
  const Logobyls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Image.asset(
            "assets/Byls-transparent.png",
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Text(
          'Byls',
          style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter Tight'),
        ),
      ],
    );
  }
}

class Datos extends StatefulWidget {
  const Datos({super.key});

  @override
  State<Datos> createState() => _DatosState();
}

class _DatosState extends State<Datos> {
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  bool obs1 = true;
  bool obs2 = true;
  Icon icono = const Icon(Icons.remove_red_eye);

  String? messageError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft, // Alinea el texto a la izquierda
            child: Text(
              'Ingresa la Nueva Contraseña',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 70, 194, 80),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              '¡Genial, ahora ingresa la nueva contraseña!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: obs1,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: icono,
                onPressed: () {
                  setState(() {
                    obs1
                        ? (
                            obs1 = false,
                            icono = const Icon(Icons.visibility_off)
                          )
                        : (obs1 = true, icono = const Icon(Icons.visibility));
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obs2,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintStyle: const TextStyle(color: Colors.grey),
              hintText: 'Confirma contraseña',
              suffixIcon: IconButton(
                icon: icono,
                onPressed: () {
                  setState(() {
                    obs2
                        ? (
                            obs2 = false,
                            icono = const Icon(Icons.visibility_off)
                          )
                        : (obs2 = true, icono = const Icon(Icons.visibility));
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          if (messageError != null) alertaPreventiva(messageError!),
          const SizedBox(
            height: 8,
          ),
          Botones(
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            onError: (String error) {
              setState(() {
                messageError = error;
              });
            },
          ),
        ],
      ),
    );
  }
}

class Botones extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(String) onError;

  const Botones(
      {super.key,
      required this.passwordController,
      required this.confirmPasswordController,
      required this.onError});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Validar que los campos no estén vacíos
              if (passwordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                return onError('Las contraseñas no pueden estar vacías');
              }
              if (passwordController.text.length < 6 &&
                  confirmPasswordController.text.length < 6) {
                return onError(
                    'La contraseña debe tener al menos 6 caracteres');
              }
              if (passwordController.text != confirmPasswordController.text) {
                return onError('Las contraseñas no coinciden');
              }

              try {
                //showValidateOTP(context);
                await authController.updatePasswordCt(passwordController.text);
                context.go('/app_entry');
              } catch (error) {
                final String capturaError = error.toString();

                if (capturaError.contains(
                    'New password should be different from the old password')) {
                  return onError(
                      'La nueva contraseña debe ser diferente a la anterior');
                }
                //return onError(error.toString());
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFF00BFA5))),
            child: const Text(
              'Recuperar Contraseña',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
          width: double.infinity,
        ),
        /* TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Volver atrás'),
        ), */
      ],
    );
  }
}

class Fondo extends StatelessWidget {
  const Fondo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF00BFA5), Color(0xFF00BFA5)])),
    );
  }
}

Container alertaPreventiva(String mensaje) {
  return Container(
    padding: const EdgeInsets.all(8.5),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(254, 207, 109, 1),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      mensaje,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

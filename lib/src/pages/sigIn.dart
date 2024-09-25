import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SigInState createState() => _SigInState();
}

class _SigInState extends State<SignIn> {
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
          Padding(
            padding: EdgeInsets.only(top: 70),
            child: Logobyls(),
          ),
          SizedBox(
            height: 20,
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
              fontSize: 25,
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obs = true;
  Icon icono = const Icon(Icons.remove_red_eye);

  // Variable para manejar el mensaje de error
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
            alignment: Alignment.centerLeft,
            child: Text(
              'Bienvenido de Nuevo',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Correo',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: obs,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintStyle: const TextStyle(color: Colors.grey),
              hintText: 'Contraseña',
              suffixIcon: IconButton(
                icon: icono,
                onPressed: () {
                  setState(() {
                    obs
                        ? (
                            obs = false,
                            icono = const Icon(Icons.visibility_off)
                          )
                        : (obs = true, icono = const Icon(Icons.visibility));
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          // Mostrar mensaje de error aquí
          if (messageError != null) alertaPreventiva(messageError!),
          const SizedBox(
            height: 8,
          ),
          const Remember(),
          const SizedBox(
            height: 8,
          ),
          Botones(
            emailController: emailController,
            passwordController: passwordController,
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

class Remember extends StatefulWidget {
  const Remember({super.key});

  @override
  State<Remember> createState() => _RememberState();
}

class _RememberState extends State<Remember> {
  bool valor = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /* Checkbox(
          value: valor,
          onChanged: (value) =>
              setState(() => valor == false ? valor = true : valor = false),
        ),
        const Text('Recordarme'), */
        const Spacer(),
        TextButton(
          onPressed: () {
            context.go('/resetPass');
          },
          style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 15)),
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
      ],
    );
  }
}

class Botones extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function(String) onError;

  const Botones({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onError,
  });

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
              try {
                await authController.signInCt(
                    emailController.text, passwordController.text);
                context.go('/app_entry');
              } catch (error) {
                final capturaError = error.toString();
                if (capturaError.contains('missing email or phone')) {
                  return onError('Por favor, ingrese correo y contraseña');
                }
                if (capturaError.contains('Invalid login credentials')) {
                  return onError('Contraseña o correo incorrecto');
                }
                if (capturaError.contains('user-disabled')) {
                  return onError('Usuario deshabilitado');
                }
                return onError('Error desconocido');
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFFFF8A65))),
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 14,
          width: double.infinity,
        ),
        TextButton(
          onPressed: () {
            context.go('/signUp');
          },
          child: const Text('¿No tienes cuenta?'),
        ),
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

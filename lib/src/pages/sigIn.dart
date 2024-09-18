import 'package:byls_app/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:flutter/material.dart';

late final AuthController authController;

class SignIn extends StatefulWidget {
  final SupabaseService supabaseService;
  const SignIn({super.key, required this.supabaseService});

  @override
  // ignore: library_private_types_in_public_api
  _SigInState createState() => _SigInState();
}

class _SigInState extends State<SignIn> {
  //Inicializa authController aquí
  /* @override
  void initState() {
    super.initState();
    // Inicializa authController aquí
    authController = AuthController();
  } */

  @override
  Widget build(BuildContext context) {
    authController = Provider.of<AuthController>(context);
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
          height: 150,
          width: 150,
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obs = true;
  Icon icono = const Icon(Icons.remove_red_eye);
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
            height: 5,
          ),
          const SizedBox(
            height: 5,
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
                )),
          ),
          const Remember(),
          const SizedBox(
            height: 30,
          ),
          Botones(
            emailController: emailController,
            passwordController: passwordController,
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
            Navigator.pushNamed(context, 'ResetPass');
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

  const Botones(
      {super.key,
      required this.emailController,
      required this.passwordController});

  @override
  Widget build(BuildContext context) {
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
                Navigator.pushReplacementNamed(context, 'Home');
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al iniciar sesión: $error')));
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFF00BFA5))),
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 25,
          width: double.infinity,
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, 'SignUp');
            },
            child: const Text('¿No tienes cuenta?'))
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

import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SigUpState createState() => _SigUpState();
}

class _SigUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        backgroundColor: const Color(0xFF044454),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/signIn');
          },
        ),
        title: const Text('Crear Cuenta', style: TextStyle(color: Colors.white)),
      ),
      body: const Stack(
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
              color: Colors.white,
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

  String? messageError;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF044454),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft, // Alinea el texto a la izquierda
            child: Text(
              'Crear Cuenta',
              style: TextStyle(
                  color: Colors.white,
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Correo',
              filled: true, 
              fillColor: const Color(0xFF04242C),
              hintStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
                borderSide: const BorderSide(color: Colors.white),
              ),
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
                borderSide: const BorderSide(color: Colors.white),
              ),
              hintStyle: const TextStyle(color: Colors.white),
              hintText: 'Contraseña',
              filled: true, 
              fillColor: const Color(0xFF04242C),
              suffixIcon: IconButton(
                icon: icono,
                onPressed: () {
                  setState(() {
                    obs
                        ? (
                            obs = false,
                            icono = const Icon(Icons.visibility_off, color: Colors.white)
                          )
                        : (obs = true, icono = const Icon(Icons.visibility, color: Colors.white));
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          // Mostrar mensaje de error
          if (messageError != null) alertaPreventiva(messageError!),
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

/*class Remember extends StatefulWidget {
  const Remember({super.key});

  @override
  State<Remember> createState() => _RememberState();
}

 class _RememberState extends State<Remember> {
  bool valor = false;
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        /* Checkbox(
          value: valor,
          onChanged: (value) =>
              setState(() => valor == false ? valor = true : valor = false),
        ),
        const Text('Recordarme'), */
        Spacer(),
        /* TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 15)),
          child: const Text('¿Olvidaste tu contraseña?'),
        ), */
      ],
    );
  }
} */

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
              // Validar errores de correo
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(emailController.text) &&
                  emailController.text.isNotEmpty) {
                return onError(
                    'Ingresa un correo válido (ejemplo@dominio.com)');
              }

              // Validar errores de contraseña
              if (passwordController.text.length < 6 &&
                  passwordController.text.isNotEmpty) {
                return onError(
                    'La contraseña debe tener al menos 6 caracteres');
              }
              //Validaciones deshabilitadas por el momento
              /* if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                      .hasMatch(passwordController) &&
                  passwordController.isNotEmpty) {
                onError(
                    'La contraseña debe tener al menos un carácter especial');
              }
              if (!RegExp(r'[a-z]').hasMatch(passwordController) &&
                  passwordController.isNotEmpty) {
                onError(
                    'La contraseña debe tener al menos una letra minúscula');
              }
              if (!RegExp(r'[A-Z]').hasMatch(passwordController) &&
                  passwordController.isNotEmpty) {
                onError(
                    'La contraseña debe tener al menos una letra mayúscula');
              } */

              // Crear cuenta
              print(passwordController.text);
              print(emailController.text);
              try {
                await authController.signUpCt(
                    emailController.text, passwordController.text);
                context.go('/app_entry');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cuenta creada con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                final String capturaError = error.toString();

                if (capturaError.contains('missing email or phone')) {
                  return onError('Por favor, ingrese correo y contraseña');
                }
                if (capturaError.contains('Invalid login credentials')) {
                  return onError('Verifica tu correo o contraseña');
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al crear la cuenta'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFFFF8A65))),
            child: const Text(
              'Crear Cuenta',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 14,
          width: double.infinity,
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
              colors: [Color(0xFF044454), Color(0xFF00BFA5)])),
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

import 'package:byls_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResetPassState createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: const Color(0xFF044454),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/signIn');
          },
        ),
        title: const Text('Recuperar contraseña', style: TextStyle(color: Colors.white)),
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
  bool obs = true;
  Icon icono = const Icon(Icons.remove_red_eye);

  //Variable del mensaje de error
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
              'Recuperar contraseña',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft, // Alinea el texto a la izquierda
            child: Text(
              'Ingresa tu correo, enviaremos un código de verificación',
              style: TextStyle(color: Colors.white),
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
              hintStyle: const TextStyle(color: Colors.grey),
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
            height: 8,
          ),
          // Mostrar mensaje de error
          if (messageError != null) alertaPreventiva(messageError!),
          const SizedBox(
            height: 8,
          ),
          Botones(
            emailController: emailController,
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
  final TextEditingController emailController;
  final Function(String) onError;

  const Botones(
      {super.key, required this.emailController, required this.onError});

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
                await authController.resetPasswordCt(emailController.text);
                showValidateOTP(context, emailController.text);
              } catch (error) {
                //onError(error.toString());
                final String capturaError = error.toString();

                if (capturaError.contains('Password recovery required email')) {
                  return onError('Por favor, ingrese el correo');
                }
                if (capturaError.contains('User not found')) {
                  return onError('Correo no válido');
                }
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFFFF8A65))),
            child: const Text(
              'Recuperar Contraseña',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 25,
          width: double.infinity,
        ),
      ],
    );
  }
}

showValidateOTP(BuildContext context, String email) {
  final codeOtp = TextEditingController();
  final authController = Provider.of<AuthController>(context, listen: false);

  Widget cancelButton = ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    onPressed: () async {
      Navigator.of(context).pop();
    },
    child: const Text("Cancelar"),
  );

  Widget continueButton = ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    onPressed: () async {
      if (codeOtp.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor ingrese un código')));
        return;
      } else {
        final response = await authController.verifyOTPandChangePassword(
          codeOtp.text,
          email,
        );

        if (response) {
          context.go('/newPass');
        } else {
          alertaPreventiva('Código incorrecto');
        }
      }
    },
    child: const Text("Ingresar"),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Ingresar código de verificación"),
        content: TextFormField(
          controller: codeOtp,
          decoration: const InputDecoration(
            hintText: 'Código verificación',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          cancelButton,
          continueButton,
        ],
      );
    },
  );
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

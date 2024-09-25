import 'package:byls_app/src/pages/home.dart';
import 'package:byls_app/src/pages/sigIn.dart';
import 'package:byls_app/src/pages/signUp.dart';
import 'package:byls_app/src/pages/resetPassword.dart';
import 'package:byls_app/src/pages/transaccion.dart';
import 'package:byls_app/src/pages/newPassword.dart';
import 'package:byls_app/src/pages/app_entry.dart';
import 'package:byls_app/src/pages/graphics.dart';
import 'package:byls_app/src/pages/report.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/* Map<String, WidgetBuilder> customRoutes(SupabaseService supabaseService) {
  return {
    "SignIn": (context) => SignIn(supabaseService: supabaseService),
    "Home": (context) => Home(supabaseService: supabaseService),
    "Transaccion": (context) => Transaccion(supabaseService:supabaseService),
    "SignUp": (context) => SignUp(supabaseService: supabaseService),
    "ResetPass": (context) => ResetPass(supabaseService: supabaseService),
    "NewPass": (context) => const NewPassword(),
    // Agrega más rutas aquí según sea necesario
  };
} */

class CustomRoutes {
  late final String matchedLocation;
  static final GoRouter router = GoRouter(
    routes: _routes, // Lista de rutas
    //errorBuilder: (context, state) => ErrorScreen(),
    initialLocation: '/home', // Ruta inicial
  );

  static final List<GoRoute> _routes = [
    GoRoute(
      path: '/signIn',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SignIn(),
      ),
    ),
    GoRoute(
      path: '/app_entry',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const NavigationClass(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const Home(),
      ),
    ),
    GoRoute(
      path: '/graficos',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const Graphics_View(),
      ),
    ),
    GoRoute(
      path: '/informe',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const Report_View(),
      ),
    ),
    GoRoute(
      path: '/signUp',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SignUp(),
      ),
    ),
    GoRoute(
      path: '/resetPass',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const ResetPass(),
      ),
    ),
    GoRoute(
      path: '/newPass',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const NewPassword(),
        );
      },
    ),
    GoRoute(
      path: '/transaccion',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const Transaccion(),
        );
      },
    ),
  ];
}

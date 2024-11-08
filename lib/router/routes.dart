import 'package:byls_app/models/cuenta_model.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/src/pages/crearCategoria.dart';
import 'package:byls_app/src/pages/currencyConvert.dart';
import 'package:byls_app/src/pages/home.dart';
import 'package:byls_app/src/pages/accountsForm.dart';
import 'package:byls_app/src/pages/transactionsAutomatics.dart';
import 'package:byls_app/src/pages/optionsSettings.dart';
import 'package:byls_app/src/pages/sigIn.dart';
import 'package:byls_app/src/pages/signUp.dart';
import 'package:byls_app/src/pages/resetPassword.dart';
import 'package:byls_app/src/pages/transaccion.dart';
import 'package:byls_app/src/pages/newPassword.dart';
import 'package:byls_app/src/pages/app_entry.dart';
import 'package:byls_app/src/pages/graphics.dart';
import 'package:byls_app/src/pages/transaccion_edit.dart';
import 'package:byls_app/src/pages/transfer_accounts.dart';
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
    initialLocation: '/signIn', // Ruta inicial
    initialExtra: null, // Extra inicial
  );
  static final GoRouter routerInit = GoRouter(
    routes: _routes, // Lista de rutas
    //errorBuilder: (context, state) => ErrorScreen(),
    initialLocation: '/app_entry', // Ruta inicial
    initialExtra: null, // Extra inicial
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
        pageBuilder: (context, state) {
          final int? seleccionarVentana = state.extra as int?;
          return MaterialPage(
            key: state.pageKey,
            child: NavigationClass(seleccionarVentana: seleccionarVentana),
          );
        }),
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
        child: const GraphicsView(),
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
    GoRoute(
      path: '/transaccionEdit',
      pageBuilder: (context, state) {
        final IncomeModel transaccion = state.extra as IncomeModel;
        return MaterialPage(
          key: state.pageKey,
          child: TransaccionEdit(transaccion: transaccion),
        );
      },
    ),
    GoRoute(
      path: '/NuevaCuenta',
      pageBuilder: (context, state) {
        final CuentaModel? cuenta = state.extra as CuentaModel?;
        return MaterialPage(
          key: state.pageKey,
          child: NewAccountMoney(cuenta: cuenta),
        );
      },
    ),
    GoRoute(
      path: '/crearCategoria',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: CrearCategoriaScreen(),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const Opciones(),
        );
      },
    ),
    GoRoute(
      path: '/cambiarDivisas',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const ConversorDivisas(),
        );
      },
    ),
    GoRoute(
      path: '/transferenciaCuentas',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const TransferAccounts(),
        );
      },
    ),
    GoRoute(
      path: '/configurarNotificaciones',
      pageBuilder: (context, state) {
        final Map<String, dynamic> parametrosTransaccion =
            state.extra as Map<String, dynamic>;
        return MaterialPage(
          key: state.pageKey,
          child: NotificationsTransactions(
            idCuenta: parametrosTransaccion['idCuenta'],
            descripcionTransaccion: parametrosTransaccion['descripcion'],
            categoriaSeleccionada: parametrosTransaccion['categoria'],
            montoTransaccion: parametrosTransaccion['cantidad'],
            tipoTransaccion: parametrosTransaccion['tipoTransaccion'],
            fechaTransaccion: parametrosTransaccion['fecha'],
          ),
        );
      },
    ),
  ];
}

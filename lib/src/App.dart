import 'package:byls_app/controllers/Transaccion_provider.dart';
import 'package:byls_app/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  final SupabaseService supabaseService;
  const MyApp({super.key, required this.supabaseService});
  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState(supabaseService: supabaseService);
}

class _MyAppState extends State<MyApp> {
  final SupabaseService supabaseService;
  _MyAppState({required this.supabaseService});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransaccionProvider()),
        Provider<AuthController>(
          create: (_) => AuthController(),
        ),
      ],
      child: MaterialApp.router(
        color: const Color(0xFF006064),
        routerConfig: CustomRoutes.router,
        debugShowCheckedModeBanner: false,
        title: "Byls",
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF006064),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 4, 117, 51),
          ),
        ),
      ),
    );
  }
}

/* class MyApp extends StatelessWidget {
  final SupabaseService supabaseService;
  const MyApp({super.key, required this.supabaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthController>(
          create: (_) => AuthController(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Byls",
          initialRoute: "Home",
          routes: customRoutes(supabaseService),
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 4, 117, 51)))),
    );
  }
} */

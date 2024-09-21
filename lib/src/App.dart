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
        Provider<AuthController>(
          create: (_) => AuthController(),
        ),
      ],
      child: MaterialApp.router(
          routerConfig: CustomRoutes.router,
          debugShowCheckedModeBanner: false,
          title: "Byls",
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 4, 117, 51)))),
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
          initialRoute: "SignIn",
          routes: customRoutes(supabaseService),
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 4, 117, 51)))),
    );
  }
} */
// ignore: file_names
import 'package:byls_app/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
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
}

/* class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final _future = Supabase.instance.client.from('countries').select();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("data"),
          backgroundColor: Colors.green,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.person),
          onPressed: () {
            debugPrint("Hello");
          },
        )
        body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final countries = snapshot.data!;
          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: ((context, index) {
              final country = countries[index];
              return ListTile(
                title: Text(country['name']),
              );
            }),
          );
        },
      ), 
        );
  } */

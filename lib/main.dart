import 'package:byls_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'src/App.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:byls_app/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vjfdvqliwmkhlkigitnt.supabase.co/',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqZmR2cWxpd21raGxraWdpdG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5MDQyMTMsImV4cCI6MjA0MTQ4MDIxM30._Q3oHnqPGwFElb9N-VL2KgW0_-V6LNjy1uygEQDIRrI',
  );

  final supabaseService = SupabaseService();

  //final authController = AuthController(Supabase.instance.client);

  runApp(MyApp(supabaseService: supabaseService));
}

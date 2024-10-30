import 'package:byls_app/services/notification_service.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'src/App.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Uniservices.init();

  //Configurar Zona Horaria de la aplicación (Para notificaciones locales)
  tz.initializeTimeZones();

  //Inicialización notificaciones locales (Android)
  await NotificationService.inicializacion(flutterLocalNotificationsPlugin);

  //Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://vjfdvqliwmkhlkigitnt.supabase.co/',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqZmR2cWxpd21raGxraWdpdG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5MDQyMTMsImV4cCI6MjA0MTQ4MDIxM30._Q3oHnqPGwFElb9N-VL2KgW0_-V6LNjy1uygEQDIRrI',
  );
  final supabaseService = SupabaseService();

  // Inicialización de la aplicación
  runApp(MyApp(supabaseService: supabaseService));
}

import 'package:byls_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'src/App.dart';
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


  // Inicialización de la aplicación
  runApp(const MyApp());
}

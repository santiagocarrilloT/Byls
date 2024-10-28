import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future inicializacion(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    //Inicialización notificaciones locales (Android)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationsTransactions extends StatefulWidget {
  const NotificationsTransactions({super.key});

  @override
  State<NotificationsTransactions> createState() =>
      _NotificationsTransactionsState();
}

class _NotificationsTransactionsState extends State<NotificationsTransactions> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  //Función para visualizar el selector de fecha
  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );
    if (fechaSeleccionada != null) {
      setState(() {
        this.fechaSeleccionada = fechaSeleccionada;
      });
    }
  }

  //Función para visualizar el selector de hora
  Future<void> seleccionarHora(BuildContext context) async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (horaSeleccionada != null) {
      setState(() {
        this.horaSeleccionada = horaSeleccionada;
      });
    }
  }

  //Función para programar la notificación
  Future _programarNotificacion(
      {required FlutterLocalNotificationsPlugin fln}) async {
    if (fechaSeleccionada != null && horaSeleccionada != null) {
      final fechaHoraNotificacion = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        horaSeleccionada!.hour,
        horaSeleccionada!.minute,
      );
      if (fechaHoraNotificacion.isAfter(DateTime.now())) {
        AndroidNotificationDetails androidPlatformChannelSpecifics =
            const AndroidNotificationDetails(
          'transaccion_channel_id',
          'Transacciones',
          playSound: true,
          importance: Importance.max,
          priority: Priority.high,
        );
        var not = NotificationDetails(android: androidPlatformChannelSpecifics);

        // Define el tiempo de la notificación
        // Convertir DateTime a TZDateTime
        final tz.TZDateTime tzFechaHoraNotificacion = tz.TZDateTime.from(
          fechaHoraNotificacion,
          tz.getLocation('America/Bogota'),
        );

        // Programa la notificación
        await flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            'Recordatorio de gasto',
            'Es hora de registrar tus gastos e ingresos',
            tzFechaHoraNotificacion,
            not,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación programada')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Selecciona una fecha y hora futura para la notificación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programar Notificación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/app_entry");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona la Fecha y Hora',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fechaSeleccionada == null
                      ? 'Fecha no seleccionada'
                      : DateFormat('yyyy-MM-dd').format(fechaSeleccionada!),
                ),
                ElevatedButton(
                  onPressed: () => seleccionarFecha(context),
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  horaSeleccionada == null
                      ? 'Hora no seleccionada'
                      : horaSeleccionada!.format(context),
                ),
                ElevatedButton(
                  onPressed: () => seleccionarHora(context),
                  child: const Text('Seleccionar Hora'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _programarNotificacion(fln: flutterLocalNotificationsPlugin);
                },
                child: const Text('Programar Notificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

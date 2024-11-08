import 'package:byls_app/controllers/ingresos_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

void callBackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) async {
//Inicialización de Supabase
      await Supabase.initialize(
        url: 'https://vjfdvqliwmkhlkigitnt.supabase.co/',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqZmR2cWxpd21raGxraWdpdG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5MDQyMTMsImV4cCI6MjA0MTQ4MDIxM30._Q3oHnqPGwFElb9N-VL2KgW0_-V6LNjy1uygEQDIRrI',
      );

      IngresosController ingresosController = IngresosController();
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      //Fecha Establecida para la transacción
      DateTime fechaTransaccion =
          DateTime.parse(inputData?['fechaHoraNotificacion']);

      //print('$fechaTransaccion y ${DateTime.now()} ////////////////////////');

      if (inputData != null && DateTime.now().isAfter(fechaTransaccion)) {
        String? idCuenta = inputData['idCuenta'];
        String? descripcionTransaccion = inputData['descripcion'];
        String? categoriaSeleccionada = inputData['categoria'];
        double? montoTransaccion = inputData['cantidad'];
        String? tipoTransaccion = inputData['tipoTransaccion'];
        DateTime? fechaTransaccion = DateTime.parse(inputData['fecha']);

        await ingresosController.insertarTransaccion(
          idCuenta!,
          descripcionTransaccion!,
          categoriaSeleccionada!,
          montoTransaccion!,
          tipoTransaccion!,
          fechaTransaccion,
        );
        print('TRANSACCION INSERTADA///////////////////');

        //Mostrar notificación de la transacción
        flutterLocalNotificationsPlugin.show(
          0,
          'Transaccion Completada',
          '${inputData['descripcion']} por ${inputData['cantidad']}',
          const NotificationDetails(
            android: AndroidNotificationDetails('channel id', 'channel name'),
          ),
        );

        //Detener la tarea
        await Workmanager().cancelAll();
      } else {
        print('TRANSACCION NO INSERTADA///////////////////, ${DateTime.now()}');
      }

      //Retornar true para indicar que la tarea se completó
      return Future.value(true);
    },
  );
}

class NotificationsTransactions extends StatefulWidget {
  final String idCuenta;
  final String descripcionTransaccion;
  final String categoriaSeleccionada;
  final double montoTransaccion;
  final String tipoTransaccion;
  final DateTime fechaTransaccion;

  const NotificationsTransactions({
    super.key,
    required this.idCuenta,
    required this.descripcionTransaccion,
    required this.categoriaSeleccionada,
    required this.montoTransaccion,
    required this.tipoTransaccion,
    required this.fechaTransaccion,
  });

  @override
  State<NotificationsTransactions> createState() =>
      _NotificationsTransactionsState();
}

class _NotificationsTransactionsState extends State<NotificationsTransactions> {
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  late String idCuenta;
  late String descripcionTransaccion;
  late String categoriaSeleccionada;
  late double montoTransaccion;
  late String tipoTransaccion;
  late DateTime fechaTransaccion;

  @override
  void initState() {
    super.initState();
    idCuenta = widget.idCuenta;
    descripcionTransaccion = widget.descripcionTransaccion;
    categoriaSeleccionada = widget.categoriaSeleccionada;
    montoTransaccion = widget.montoTransaccion;
    tipoTransaccion = widget.tipoTransaccion;
    fechaTransaccion = widget.fechaTransaccion;
  }

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
  Future _programarNotificacion() async {
    /*final fechaHoraNotificacion = DateTime(
      fechaSeleccionada!.year,
      fechaSeleccionada!.month,
      fechaSeleccionada!.day,
      horaSeleccionada!.hour,
      horaSeleccionada!.minute,
    );*/

    /* final Map<String, dynamic> inputDatas = {
      'idCuenta': idCuenta,
      'descripcion': descripcionTransaccion,
      'categoria': categoriaSeleccionada,
      'cantidad': montoTransaccion,
      'tipoTransaccion': tipoTransaccion,
      'fecha': fechaTransaccion.toIso8601String(),
    };
    //Inicializar el WorkManager
    await Workmanager().initialize(callBackDispatcher, isInDebugMode: false);

    await Workmanager().registerOneOffTask(
      '0',
      'PrimerTarea',
      inputData: inputDatas,
      initialDelay: const Duration(seconds: 2),
    ); */

    if (fechaSeleccionada != null && horaSeleccionada != null) {
      final fechaHoraNotificacion = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        horaSeleccionada!.hour,
        horaSeleccionada!.minute,
      );

      print(fechaHoraNotificacion);

      //Valores que ingresarán al WorkManager
      final Map<String, dynamic> inputDatas = {
        'idCuenta': idCuenta,
        'descripcion': descripcionTransaccion,
        'categoria': categoriaSeleccionada,
        'cantidad': montoTransaccion,
        'tipoTransaccion': tipoTransaccion,
        'fecha': fechaTransaccion.toIso8601String(),
        'fechaHoraNotificacion': fechaHoraNotificacion.toIso8601String(),
      };

      //Inicializar el WorkManager
      await Workmanager().initialize(callBackDispatcher, isInDebugMode: false);

      //Registrar la tarea en el WorkManager
      await Workmanager().registerPeriodicTask(
        '0',
        'Transaccion Programada',
        inputData: inputDatas,
        frequency: const Duration(minutes: 15),
      );

      /* if (fechaHoraNotificacion.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación programada')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Selecciona una fecha y hora futura para la notificación')),
        );
      } */
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
                  _programarNotificacion();
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

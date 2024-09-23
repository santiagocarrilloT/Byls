import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  bool isGastosSelected = true;
  String? selectedCategory;
  DateTime? selectedDate;
  bool showCalendar = false;
  final TextEditingController montoController = TextEditingController();
  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController etiquetaController = TextEditingController();

  Map<DateTime, String> etiquetas = {};

  final List<Map<String, dynamic>> gastos = [
    {'nombre': 'Casa', 'icono': Icons.home},
    {'nombre': 'Educación', 'icono': Icons.school},
    {'nombre': 'Moto', 'icono': Icons.motorcycle},
    {'nombre': 'Alimentos', 'icono': Icons.fastfood},
    {'nombre': 'Teléfono', 'icono': Icons.phone},
    {'nombre': 'Gasolina', 'icono': Icons.local_gas_station},
  ];

  final List<Map<String, dynamic>> ingresos = [
    {'nombre': 'Salario', 'icono': Icons.attach_money},
    {'nombre': 'Venta', 'icono': Icons.store},
    {'nombre': 'Inversiones', 'icono': Icons.trending_up},
    {'nombre': 'Otro', 'icono': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    final categories = isGastosSelected ? gastos : ingresos;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Transacción"),
      ),
      body: Column(
        children: [
          // Botones de Gastos/Ingreso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isGastosSelected = true;
                    selectedCategory = null;
                  });
                },
                child: Text(
                  'Gastos',
                  style: TextStyle(
                    color: isGastosSelected ? Color(0xFF00BFA5) : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isGastosSelected = false;
                    selectedCategory = null;
                  });
                },
                child: Text(
                  'Ingreso',
                  style: TextStyle(
                    color: !isGastosSelected ? Color(0xFF00BFA5) : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Lista de categorías
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Aumentamos el número de columnas para agrupar más
                crossAxisSpacing: 10,  // Reducimos el espacio horizontal entre iconos
                mainAxisSpacing: 10,   // Reducimos el espacio vertical entre iconos
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category['nombre'] == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['nombre'];
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 25,  // Reducimos el tamaño del círculo
                        backgroundColor: isSelected ? Color(0xFF00BFA5) : Colors.grey[300],
                        child: Icon(
                          category['icono'],
                          color: isSelected ? Colors.white : Colors.black,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 5), // Reducimos el espacio entre el icono y el texto
                      Text(
                        category['nombre'],
                        style: const TextStyle(
                          fontSize: 12,  // Reducimos el tamaño del texto para mejor ajuste
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Calendario y campos en la parte inferior
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Botones de fechas y calendario
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime.now();
                        });
                      },
                      child: const Text('Hoy'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime.now().subtract(Duration(days: 1));
                        });
                      },
                      child: const Text('Ayer'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime.now().subtract(Duration(days: 7));
                        });
                      },
                      child: const Text('Último'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        setState(() {
                          showCalendar = !showCalendar;
                        });
                      },
                    ),
                  ],
                ),

                // Calendario desplegable
                if (showCalendar)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 5,
                      child: TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: selectedDate ?? DateTime.now(),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            selectedDate = selectedDay;
                            showCalendar = false;
                          });
                          _mostrarDialogoEtiqueta(context, selectedDay);
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF00BFA5),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Campo de monto y comentario
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: montoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: comentarioController,
                        decoration: const InputDecoration(
                          labelText: 'Comentario',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                
                // Botón de confirmación
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategory != null && montoController.text.isNotEmpty) {
                      print('Transacción añadida:');
                      print('Categoría: $selectedCategory');
                      print('Monto: ${montoController.text}');
                      print('Comentario: ${comentarioController.text}');
                      print('Fecha: $selectedDate');
                    } else {
                      print('Faltan datos para la transacción');
                    }
                  },
                  child: const Text('Agregar Transacción'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Función para mostrar un cuadro de diálogo para añadir una etiqueta
  void _mostrarDialogoEtiqueta(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Etiqueta'),
          content: TextField(
            controller: etiquetaController,
            decoration: const InputDecoration(
              hintText: 'Escribe una etiqueta',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  etiquetas[selectedDay] = etiquetaController.text;
                });
                etiquetaController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

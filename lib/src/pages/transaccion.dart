import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/src/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  bool isGastosSelected = true; // Para alternar entre Gastos e Ingresos
  String? selectedCategory; // Para almacenar la categoría seleccionada
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada (por defecto, la actual)
  final TextEditingController _cantidadController = TextEditingController(); // Controlador para la cantidad
  final TextEditingController _descripcionController = TextEditingController(); // Controlador para la descripción

  final List<Map<String, dynamic>> gastos = [
    {'nombre': 'Casa', 'icono': Icons.home, 'id': 1},
    {'nombre': 'Educación', 'icono': Icons.school, 'id': 2},
    {'nombre': 'Moto', 'icono': Icons.motorcycle, 'id': 3},
    {'nombre': 'Alimentos', 'icono': Icons.fastfood, 'id': 4},
    {'nombre': 'Teléfono', 'icono': Icons.phone_android, 'id': 5},
    {'nombre': 'Gasolina', 'icono': Icons.local_gas_station, 'id': 6},
  ];

  final List<Map<String, dynamic>> ingresos = [
    {'nombre': 'Salario', 'icono': Icons.attach_money, 'id': 7},
    {'nombre': 'Venta', 'icono': Icons.store, 'id': 8},
    {'nombre': 'Inversiones', 'icono': Icons.trending_up, 'id': 9},
  ];

  // Función para abrir el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Crea una instancia de AuthController
  final AuthController authController = AuthController();

  Future<void> _guardarTransaccion() async {
    if (selectedCategory == null || _cantidadController.text.isEmpty || _descripcionController.text.isEmpty) {
      // Mostrar un mensaje de error si falta algún campo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    try {
      final idCategoria = isGastosSelected
          ? gastos.firstWhere((g) => g['nombre'] == selectedCategory)['id']
          : ingresos.firstWhere((i) => i['nombre'] == selectedCategory)['id'];

      final tipoTransaccion = isGastosSelected ? 'Gasto' : 'Ingreso';

      // Prints para depuración
      print('Descripción: ${_descripcionController.text}');
      print('ID Categoría: $idCategoria');
      print('Monto: ${_cantidadController.text}');
      print('Tipo de Transacción: $tipoTransaccion');
      print('Fecha de Transacción: $selectedDate');

      // Llamar al método insertarTransaccion del AuthController
      await authController.insertarTransaccion(
        descripcion: _descripcionController.text,
        nombre_categoria: idCategoria,
        montoTransaccion: double.parse(_cantidadController.text),
        tipoTransaccion: tipoTransaccion,
        fechaTransaccion: selectedDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción guardada con éxito')),
      );

      // Redirigir al usuario después de guardar la transacción
      context.go("/home");
    } catch (e) {
      print('Error al guardar la transacción: $e');  // Print para ver el error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la transacción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = isGastosSelected ? gastos : ingresos;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/home");
          },
        ),
        title: const Text("Transacción"),
      ),
      backgroundColor: const Color(0xFF006064),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Gastos e Ingreso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isGastosSelected = true;
                        selectedCategory = null; // Reiniciar la selección
                      });
                    },
                    child: Text(
                      'Gastos',
                      style: TextStyle(
                        color: isGastosSelected
                            ? const Color(0xFF00BFA5)
                            : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isGastosSelected = false;
                        selectedCategory = null; // Reiniciar la selección
                      });
                    },
                    child: Text(
                      'Ingreso',
                      style: TextStyle(
                        color: !isGastosSelected
                            ? const Color(0xFF00BFA5)
                            : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Categorías
              SizedBox(
                height: 350, // Altura para hacer scroll a las categorias
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Tres columnas
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1, // Ajustar la proporción del ítem
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
                            radius: 30,
                            backgroundColor: isSelected
                                ? const Color(0xFF00BFA5)
                                : Colors.grey[300],
                            child: Icon(
                              category['icono'],
                              color: isSelected ? Colors.white : Colors.black,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['nombre'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Selector de fecha
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Seleccionar fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo para ingresar la cantidad
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly, // Solo números permitidos
                ],
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BFA5)),
                  ),                  
                ),
              ),
              const SizedBox(height: 20),

              // Campo para la descripción
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BFA5)),
                  ),                  
                ),
              ),
              const SizedBox(height: 20),

              // Botón para guardar transacción
              Center(
                child: ElevatedButton(
                  onPressed: _guardarTransaccion,
                  child: const Text('Guardar Transacción'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



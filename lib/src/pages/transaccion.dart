import 'package:byls_app/src/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:byls_app/services/supabase_service.dart';
import 'package:go_router/go_router.dart';


class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  bool isGastosSelected = true; // Para alternar entre Gastos e Ingresos
  String? selectedCategory; // Para almacenar la categoría seleccionada

  final List<Map<String, dynamic>> gastos = [
    {'nombre': 'Casa', 'icono': Icons.home},
    {'nombre': 'Educación', 'icono': Icons.school},
    {'nombre': 'Moto', 'icono': Icons.motorcycle},
    {'nombre': 'Alimentos', 'icono': Icons.fastfood},
    {'nombre': 'Teléfono', 'icono': Icons.phone_android},
    {'nombre': 'Gasolina', 'icono': Icons.local_gas_station,},
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
    if (selectedCategory == null ||
        _cantidadController.text.isEmpty ||
        _descripcionController.text.isEmpty) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción guardada con éxito')),
      );

      // Redirigir al usuario después de guardar la transacción
      context.go("/home");
    } catch (e) {
      print('Error al guardar la transacción: $e'); // Print para ver el error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la transacción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isGastosSelected = true;
                    selectedCategory = null; // Reiniciar la selección
                  });
                  print("Gastos seleccionado");
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
                    selectedCategory = null; // Reiniciar la selección
                  });
                  print("Ingreso seleccionado");
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
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Tres columnas
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
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
                    print('${category['nombre']} seleccionado');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isSelected ? Color(0xFF00BFA5) : Colors.grey[300],
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
        ],
      ),
    );
  }
}



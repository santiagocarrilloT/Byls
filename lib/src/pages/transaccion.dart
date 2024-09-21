import 'package:flutter/material.dart';
import 'package:byls_app/services/supabase_service.dart';


class Transaccion extends StatefulWidget {
  const Transaccion({super.key, required SupabaseService supabaseService});
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
            Navigator.pushReplacementNamed(context, 'Home');
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



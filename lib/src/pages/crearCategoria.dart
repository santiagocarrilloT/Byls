import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:byls_app/controllers/categoriasNew_controller.dart'; // Importamos el AuthController

class CrearCategoriaScreen extends StatefulWidget {
  @override
  _CrearCategoriaScreenState createState() => _CrearCategoriaScreenState();
}

class _CrearCategoriaScreenState extends State<CrearCategoriaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  Color selectedColor = Colors.blue; // Color por defecto
  String tipoSeleccionado = 'Gasto'; // Tipo por defecto
  IconData? iconoSeleccionado;

  // Crea una instancia de AuthController
  final AuthController authController = AuthController();

  
  // Iconos para categorías de gastos
  final Map<IconData, String> iconosGastos = {
    // Hogar y Vida Diaria
    Icons.home: 'house',
    Icons.kitchen: 'kitchen',
    Icons.bed: 'bed',
    Icons.weekend: 'living_room',
    Icons.bathtub: 'bathroom',
    Icons.lightbulb: 'electricity',
    
    // Transporte
    Icons.directions_car: 'car',
    Icons.motorcycle: 'motorcycle',
    Icons.directions_bus: 'bus',
    Icons.directions_bike: 'bike',
    Icons.local_shipping: 'shipping',
    Icons.airplanemode_active: 'airplane',
    Icons.train: 'train',
    Icons.subway: 'subway',
    
    // Alimentos y Bebidas
    Icons.local_pizza: 'pizza',
    Icons.local_cafe: 'cafe',
    Icons.local_dining: 'restaurant',

    // Entretenimiento
    Icons.movie: 'movie',
    Icons.music_note: 'music',
    Icons.tv: 'tv',
    Icons.book: 'book',
    
    // Salud y Bienestar
    Icons.fitness_center: 'gym',
    Icons.medical_services: 'medical_services',
    Icons.health_and_safety: 'health_and_safety',
    Icons.spa: 'spa',
    Icons.self_improvement: 'meditation',
    
    // Otros
    Icons.shopping_cart: 'shopping_cart',
    Icons.shopping_bag: 'shopping_bag',
    Icons.pets: 'pets',
  };

  // Iconos para categorías de ingresos
  final Map<IconData, String> iconosIngresos = {
    // Finanzas y Negocios
    Icons.attach_money: 'money',
    Icons.trending_up: 'investment',
    Icons.monetization_on: 'savings',
    Icons.account_balance_wallet: 'wallet',
    Icons.business: 'business',
    
    // Trabajo y Educación
    Icons.school: 'school',
    Icons.science: 'science',
    Icons.work: 'work',
    Icons.engineering: 'engineering',

    // Viajes y Ocio
    Icons.explore: 'explore',
    Icons.beach_access: 'beach',
    
    // Tecnología
    Icons.phone_android: 'smartphone',
    Icons.computer: 'computer',
    Icons.devices: 'devices',
  };


  // Guardar categoría en la base de datos usando AuthController
  Future<void> _guardarCategoria() async {
    final nombre = _nombreController.text;

    if (nombre.isEmpty || iconoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    try {
      // Convertir el color a formato 0xFF (valor hexadecimal estilo Dart)
      String colorHex =
          '0x${selectedColor.value.toRadixString(16).toUpperCase()}';

      // Obtener el nombre del ícono seleccionado
      final Map<IconData, String> iconosDisponibles =
          tipoSeleccionado == 'Gasto' ? iconosGastos : iconosIngresos;
      String nombreIcono =
          iconosDisponibles[iconoSeleccionado] ?? 'icono_desconocido';

      // Llamamos a la función en AuthController para guardar la categoría
      await authController.insertarCategoria(
        nombre,
        colorHex, // Guardamos el color en formato 0xFFFFFFFF
        tipoSeleccionado,
        nombreIcono, // Guardamos el nombre del ícono
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría guardada con éxito.')),
      );

      context.go("/transaccion");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la categoría: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Iconos disponibles según el tipo seleccionado (Gasto o Ingreso)
    final Map<IconData, String> iconosDisponibles =
        tipoSeleccionado == 'Gasto' ? iconosGastos : iconosIngresos;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF044454),
        title: const Text("Crear Categoría", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go("/transaccion");
          },
        ),
      ),
      body: Container(
        color: const Color(0xFF04242C),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de texto para el nombre de la categoría
              TextField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre de la Categoría',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF044454),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFF00BFA5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selector de color
              Row(
                children: [
                  const Text('Selecciona un color: ',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final Color? pickedColor = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF044454),
                            title: const Text('Selecciona un color',
                                style: TextStyle(color: Colors.white)),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (color) {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                  Navigator.of(context).pop(color);
                                },
                              ),
                            ),
                          );
                        },
                      );
                      if (pickedColor != null) {
                        setState(() {
                          selectedColor = pickedColor;
                        });
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: selectedColor,
                      radius: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector de tipo (Gasto o Ingreso)
              DropdownButton<String>(
                value: tipoSeleccionado,
                dropdownColor: const Color(0xFF044454),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'Ingreso', child: Text('Ingreso')),
                ],
                onChanged: (value) {
                  setState(() {
                    tipoSeleccionado = value!;
                    iconoSeleccionado =
                        null; // Reiniciar el ícono seleccionado al cambiar el tipo
                  });
                },
              ),
              const SizedBox(height: 20),

              // Selección de íconos
              const Text('Selecciona un ícono:',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: iconosDisponibles.keys.map((icon) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            iconoSeleccionado = icon;
                          });
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: iconoSeleccionado == icon
                              ? selectedColor
                              : Colors.grey[700],
                          child: Icon(
                            icon,
                            color: iconoSeleccionado == icon
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

              // Botón para guardar la categoría
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF044454),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: _guardarCategoria,
                  child: const Text('Guardar Categoría',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  // Iconos para categorías de gastos y sus nombres
  final Map<IconData, String> iconosGastos = {
    Icons.home: 'house',
    Icons.school: 'school',
    Icons.fastfood: 'fastfood',
    Icons.local_gas_station: 'local_gas_station',
    Icons.phone_android: 'phone_android',
    Icons.shopping_cart: 'shopping_cart',
    Icons.car_rental: 'car_rental',
    Icons.hotel: 'hotel',
    Icons.health_and_safety: 'health_and_safety',
  };

  // Iconos para categorías de ingresos y sus nombres
  final Map<IconData, String> iconosIngresos = {
    Icons.attach_money: 'attach_money',
    Icons.trending_up: 'trending_up',
    Icons.monetization_on: 'monetization_on',
    Icons.account_balance_wallet: 'account_balance_wallet',
    Icons.business: 'business',
    Icons.card_giftcard: 'card_giftcard',
    Icons.store: 'store',
    Icons.pie_chart: 'pie_chart',
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
      String colorHex = '0x${selectedColor.value.toRadixString(16).toUpperCase()}';

      // Obtener el nombre del ícono seleccionado
      final Map<IconData, String> iconosDisponibles = tipoSeleccionado == 'Gasto' ? iconosGastos : iconosIngresos;
      String nombreIcono = iconosDisponibles[iconoSeleccionado] ?? 'icono_desconocido';

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
    final Map<IconData, String> iconosDisponibles = tipoSeleccionado == 'Gasto' ? iconosGastos : iconosIngresos;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/transaccion");
          },
        ),
        title: const Text("Crear Categoría"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para el nombre de la categoría
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
            ),
            const SizedBox(height: 20),

            // Selector de color
            Row(
              children: [
                const Text('Selecciona un color: '),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final Color? pickedColor = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Selecciona un color'),
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
              items: const [
                DropdownMenuItem(value: 'Gasto', child: Text('Gasto')),
                DropdownMenuItem(value: 'Ingreso', child: Text('Ingreso')),
              ],
              onChanged: (value) {
                setState(() {
                  tipoSeleccionado = value!;
                  iconoSeleccionado = null; // Reiniciar el ícono seleccionado al cambiar el tipo
                });
              },
            ),
            const SizedBox(height: 20),

            // Selección de íconos
            const Text('Selecciona un ícono:'),
            const SizedBox(height: 10),
            Wrap(
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
                    radius: 25,
                    backgroundColor: iconoSeleccionado == icon ? selectedColor : Colors.grey[300],
                    child: Icon(icon, color: iconoSeleccionado == icon ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Botón para guardar la categoría
            ElevatedButton(
              onPressed: _guardarCategoria,
              child: const Text('Guardar Categoría'),
            ),
          ],
        ),
      ),
    );
  }
}

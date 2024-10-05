import 'package:byls_app/controllers/auth_controller.dart';
import 'package:byls_app/models/transacciones_model.dart';
import 'package:byls_app/src/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:byls_app/src/pages/crearCategoria.dart';
import 'package:byls_app/models/categorias.dart';

class Transaccion extends StatefulWidget {
  const Transaccion({super.key});
  @override
  State<Transaccion> createState() => _TransaccionState();
}

class _TransaccionState extends State<Transaccion> {
  bool isGastosSelected = true; // Alternar entre Gastos e Ingresos
  String? selectedCategory; // Categoría seleccionada
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  //Función para seleccionar la fecha
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
      final double cantidad = double.parse(_cantidadController.text);
      final tipoTransaccion = isGastosSelected ? 'Gasto' : 'Ingreso';

      // Insertar la transacción en la base de datos usando AuthController
      await authController.insertarTransaccion(
        _descripcionController.text,
        selectedCategory!,
        cantidad,
        tipoTransaccion,
        selectedDate,
      );

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción guardada con éxito')),
      );
      context.go("/app_entry");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la transacción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las categorías según el tipo seleccionado
    final categories = isGastosSelected ? categoriasGasto : categoriasIngreso;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go("/app_entry");
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
                        selectedCategory = null;
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
              SizedBox(
                height: 350,
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return GestureDetector(
                        onTap: () {
                          // Al tocar, redirigir a la ventana de crear categoría
                          context.go("/crearCategoria");
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Crear',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final category = categories[index];
                    final isSelected = category.nombre == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category.nombre;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isSelected
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : category.color,
                            child: Icon(
                              category.icono,
                              color: isSelected ? Colors.white : Colors.black,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.nombre,
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
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
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

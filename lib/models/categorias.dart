import 'package:flutter/material.dart';

// Clase de Categoría
class Categoria {
  final int id;
  final String nombre;
  final IconData icono;
  final Color color;

  Categoria({required this.id, required this.nombre, required this.icono, required this.color});
}


// Listas de categorías predefinidas para Gastos
final List<Categoria> categoriasGasto = [
  Categoria(id: 1, nombre: 'Casa', icono: Icons.home, color: Colors.blue),
  Categoria(id: 2, nombre: 'Educación', icono: Icons.school, color: Colors.green),
  Categoria(id: 3, nombre: 'Gasolina', icono: Icons.local_gas_station, color: Colors.red),
  Categoria(id: 4, nombre: 'Moto', icono: Icons.motorcycle, color: Colors.purple),
  Categoria(id: 5, nombre: 'Teléfono', icono: Icons.phone_android, color: Colors.orange),
  Categoria(id: 6, nombre: 'Alimentación', icono: Icons.fastfood, color: Colors.brown),
  Categoria(id: 7, nombre: 'TV', icono: Icons.movie, color: Colors.pink),
  Categoria(id: 8, nombre: 'Salud', icono: Icons.local_hospital, color: Colors.blueAccent),
  Categoria(id: 9, nombre: 'Ropa', icono: Icons.checkroom, color: Colors.amber),
  Categoria(id: 10, nombre: 'Viajes', icono: Icons.airplanemode_active, color: Colors.lightBlue),
  Categoria(id: 11, nombre: 'Suscripciones', icono: Icons.subscriptions, color: Colors.deepPurple),
];

// Listas de categorías predefinidas para Ingresos
final List<Categoria> categoriasIngreso = [
  Categoria(id: 12, nombre: 'Salario', icono: Icons.attach_money, color: Colors.teal),
  Categoria(id: 13, nombre: 'Inversiones', icono: Icons.trending_up, color: Colors.orange),
  Categoria(id: 14, nombre: 'Venta', icono: Icons.store, color: Colors.green),
  Categoria(id: 15, nombre: 'Freelance', icono: Icons.work, color: Colors.indigo),
  Categoria(id: 16, nombre: 'Regalos', icono: Icons.card_giftcard, color: Colors.redAccent),
  Categoria(id: 17, nombre: 'Alquiler', icono: Icons.apartment, color: Colors.brown),
  Categoria(id: 18, nombre: 'Bonificaciones', icono: Icons.star, color: Colors.yellow),
  Categoria(id: 19, nombre: 'Intereses', icono: Icons.account_balance, color: Colors.tealAccent),
  Categoria(id: 20, nombre: 'Dividendos', icono: Icons.paid, color: Colors.greenAccent),
];
import 'package:flutter/material.dart';
import 'package:byls_app/controllers/categoriasUsuario_controller.dart'; // Controlador de BD


import 'categoriasPredeterminadas.dart'; // Archivo con las categorías predefinidas

class Categoria {
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
}

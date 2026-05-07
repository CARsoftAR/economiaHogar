import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isIncome,
  });

  static const List<CategoryModel> categories = [
    // Egresos
    CategoryModel(id: 'rent', name: 'Alquiler', icon: Icons.home_rounded, color: Color(0xFF5C6BC0), isIncome: false),
    CategoryModel(id: 'grocery', name: 'Súper', icon: Icons.shopping_cart_rounded, color: Color(0xFFFFCA28), isIncome: false), // Amarillo cálido
    CategoryModel(id: 'bills', name: 'Facturas', icon: Icons.receipt_long_rounded, color: Color(0xFFFF7043), isIncome: false), // Naranja sutil
    CategoryModel(id: 'leisure', name: 'Ocio', icon: Icons.movie_filter_rounded, color: Color(0xFFAB47BC), isIncome: false), // Púrpura suave
    CategoryModel(id: 'health', name: 'Salud', icon: Icons.medical_services_rounded, color: Color(0xFF26A69A), isIncome: false),
    CategoryModel(id: 'transport', name: 'Transporte', icon: Icons.directions_bus_rounded, color: Color(0xFF42A5F5), isIncome: false),
    CategoryModel(id: 'education', name: 'Educación', icon: Icons.school_rounded, color: Color(0xFF8D6E63), isIncome: false),
    
    // Ingresos
    CategoryModel(id: 'salary', name: 'Sueldo', icon: Icons.payments_rounded, color: Color(0xFF66BB6A), isIncome: true), // Verde esmeralda
    CategoryModel(id: 'sales', name: 'Ventas', icon: Icons.sell_rounded, color: Color(0xFF26C6DA), isIncome: true),
    CategoryModel(id: 'investment', name: 'Inversiones', icon: Icons.trending_up_rounded, color: Color(0xFFFFA726), isIncome: true),
    CategoryModel(id: 'gifts', name: 'Regalos', icon: Icons.card_giftcard_rounded, color: Color(0xFFEC407A), isIncome: true),
    CategoryModel(id: 'others', name: 'Otros', icon: Icons.more_horiz_rounded, color: Color(0xFF78909C), isIncome: true),
  ];

  static CategoryModel getById(String id) {
    return categories.firstWhere((c) => c.id == id, orElse: () => categories.last);
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': icon.codePoint,
      'color_hex': color.value,
      'is_income': isIncome ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon_code'], fontFamily: 'MaterialIcons'),
      color: Color(map['color_hex']),
      isIncome: map['is_income'] == 1,
    );
  }

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(id: 'rent', name: 'Alquiler', icon: Icons.home_rounded, color: Color(0xFF5C6BC0), isIncome: false),
    CategoryModel(id: 'grocery', name: 'Súper', icon: Icons.shopping_cart_rounded, color: Color(0xFFFFCA28), isIncome: false),
    CategoryModel(id: 'bills', name: 'Facturas', icon: Icons.receipt_long_rounded, color: Color(0xFFFF7043), isIncome: false),
    CategoryModel(id: 'leisure', name: 'Ocio', icon: Icons.movie_filter_rounded, color: Color(0xFFAB47BC), isIncome: false),
    CategoryModel(id: 'salary', name: 'Sueldo', icon: Icons.payments_rounded, color: Color(0xFF66BB6A), isIncome: true),
    CategoryModel(id: 'sales', name: 'Ventas', icon: Icons.sell_rounded, color: Color(0xFF26C6DA), isIncome: true),
    CategoryModel(id: 'others', name: 'Otros', icon: Icons.more_horiz_rounded, color: Color(0xFF78909C), isIncome: false),
  ];

  // Helper para mantener compatibilidad mientras migramos
  static CategoryModel getById(String id, {List<CategoryModel>? customCategories}) {
    final all = [...defaultCategories, ...(customCategories ?? [])];
    return all.firstWhere((c) => c.id == id, orElse: () => defaultCategories.last);
  }
}

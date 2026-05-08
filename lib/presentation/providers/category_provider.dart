import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository repository;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  CategoryProvider({required this.repository});

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get incomeCategories => _categories.where((c) => c.isIncome).toList();
  List<CategoryModel> get expenseCategories => _categories.where((c) => !c.isIncome).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    _categories = await repository.getAllCategories();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await repository.addCategory(category);
    await fetchCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await repository.updateCategory(category);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await repository.deleteCategory(id);
    await fetchCategories();
  }

  CategoryModel getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryModel.defaultCategories.last,
    );
  }
}

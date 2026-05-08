import '../../core/database/database_helper.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class SqliteCategoryRepository implements CategoryRepository {
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}

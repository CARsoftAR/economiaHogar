import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('economy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Subimos a la v4 para los recordatorios
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN categoryId TEXT NOT NULL DEFAULT "others"');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon_code INTEGER NOT NULL,
          color_hex INTEGER NOT NULL,
          is_income INTEGER NOT NULL
        )
      ''');
      await _seedDefaultCategories(db);
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          due_date TEXT NOT NULL,
          type TEXT NOT NULL,
          is_completed INTEGER NOT NULL
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        categoryId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_hex INTEGER NOT NULL,
        is_income INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        type TEXT NOT NULL,
        is_completed INTEGER NOT NULL
      )
    ''');

    await _seedDefaultCategories(db);
    await _seedInitialData(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    for (var category in CategoryModel.defaultCategories) {
      await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM transactions'));
    if (count == 0) {
      final now = DateTime.now();
      final mockData = [
        {'amount': 50000.0, 'description': 'Sueldo Mayo', 'date': now.subtract(const Duration(days: 5)).toIso8601String(), 'isIncome': 1, 'categoryId': 'salary'},
        {'amount': 12500.0, 'description': 'Alquiler Depto', 'date': now.subtract(const Duration(days: 4)).toIso8601String(), 'isIncome': 0, 'categoryId': 'rent'},
        {'amount': 4500.0, 'description': 'Compra Coto', 'date': now.subtract(const Duration(days: 3)).toIso8601String(), 'isIncome': 0, 'categoryId': 'grocery'},
        {'amount': 2100.0, 'description': 'Luz y Gas', 'date': now.subtract(const Duration(days: 2)).toIso8601String(), 'isIncome': 0, 'categoryId': 'bills'},
        {'amount': 1500.0, 'description': 'Salida Cine', 'date': now.subtract(const Duration(days: 1)).toIso8601String(), 'isIncome': 0, 'categoryId': 'leisure'},
        {'amount': 3000.0, 'description': 'Venta Laptop', 'date': now.toIso8601String(), 'isIncome': 1, 'categoryId': 'sales'},
      ];
      for (var data in mockData) {
        await db.insert('transactions', data);
      }
    }
  }

  // Métodos de consulta existentes... (omitidos para brevedad pero se mantienen)
  Future<Map<String, double>> getMonthlyStats(DateTime month) async {
    final db = await database;
    final firstDay = DateTime(month.year, month.month, 1).toIso8601String();
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();
    final result = await db.rawQuery('SELECT isIncome, SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ? GROUP BY isIncome', [firstDay, lastDay]);
    double income = 0;
    double expense = 0;
    for (var row in result) {
      if (row['isIncome'] == 1) income = row['total'] as double;
      else expense = row['total'] as double;
    }
    return {'income': income, 'expense': expense};
  }

  Future<List<Map<String, dynamic>>> getCategoryStats(DateTime month) async {
    final db = await database;
    final firstDay = DateTime(month.year, month.month, 1).toIso8601String();
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();
    return await db.rawQuery('SELECT categoryId, SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ? AND isIncome = 0 GROUP BY categoryId ORDER BY total DESC', [firstDay, lastDay]);
  }
}

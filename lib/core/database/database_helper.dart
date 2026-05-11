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
      version: 6, // Subimos a la v6 para categoría en recordatorios
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
    if (oldVersion < 5) {
      await db.execute('CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)');
      await db.insert('settings', {'key': 'monthly_limit', 'value': '100000'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE reminders ADD COLUMN categoryId TEXT NOT NULL DEFAULT "others"');
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
      CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        type TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        categoryId TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)');
    await db.insert('settings', {'key': 'monthly_limit', 'value': '100000'}, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _seedDefaultCategories(db);
    await _seedInitialData(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    for (var category in CategoryModel.defaultCategories) {
      await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedInitialData(Database db) async {
    // Método vacío para que la app inicie limpia sin datos de demostración
  }

  // Métodos de consulta existentes... (omitidos para brevedad pero se mantienen)
  Future<Map<String, double>> getStatsByRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    final result = await db.rawQuery('SELECT isIncome, SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ? GROUP BY isIncome', [startStr, endStr]);
    double income = 0;
    double expense = 0;
    for (var row in result) {
      if (row['isIncome'] == 1) income = (row['total'] as num).toDouble();
      else expense = (row['total'] as num).toDouble();
    }
    return {'income': income, 'expense': expense};
  }

  Future<List<Map<String, dynamic>>> getCategoryStatsByRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    return await db.rawQuery('SELECT categoryId, SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ? AND isIncome = 0 GROUP BY categoryId ORDER BY total DESC', [startStr, endStr]);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isNotEmpty) return result.first['value'] as String;
    return null;
  }

  Future<void> updateSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('reminders');
  }
}

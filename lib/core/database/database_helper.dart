import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN categoryId TEXT NOT NULL DEFAULT "others"');
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
  }

  Future<Map<String, double>> getMonthlyStats(DateTime month) async {
    final db = await instance.database;
    final firstDay = DateTime(month.year, month.month, 1).toIso8601String();
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT isIncome, SUM(amount) as total 
      FROM transactions 
      WHERE date >= ? AND date <= ?
      GROUP BY isIncome
    ''', [firstDay, lastDay]);

    double income = 0;
    double expense = 0;

    for (var row in result) {
      if (row['isIncome'] == 1) {
        income = row['total'] as double;
      } else {
        expense = row['total'] as double;
      }
    }

    return {'income': income, 'expense': expense};
  }

  Future<List<Map<String, dynamic>>> getCategoryStats(DateTime month) async {
    final db = await instance.database;
    final firstDay = DateTime(month.year, month.month, 1).toIso8601String();
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    return await db.rawQuery('''
      SELECT categoryId, SUM(amount) as total 
      FROM transactions 
      WHERE date >= ? AND date <= ? AND isIncome = 0
      GROUP BY categoryId
      ORDER BY total DESC
    ''', [firstDay, lastDay]);
  }

  Future<void> seedMockData() async {
    final db = await instance.database;
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

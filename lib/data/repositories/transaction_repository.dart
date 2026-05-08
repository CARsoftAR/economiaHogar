import '../../core/database/database_helper.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class SqliteTransactionRepository implements TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  SqliteTransactionRepository();

  @override
  Future<List<TransactionModel>> getAllTransactions({DateTime? month}) async {
    final db = await dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (month != null) {
      final start = DateTime(month.year, month.month, 1).toIso8601String();
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();
      where = 'date >= ? AND date <= ?';
      whereArgs = [start, end];
    }

    final result = await db.query(
      'transactions', 
      where: where, 
      whereArgs: whereArgs, 
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    await db.insert('transactions', transaction.toMap());
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<double> getBalance() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(CASE WHEN isIncome = 1 THEN amount ELSE -amount END) as total FROM transactions');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<Map<String, double>> getMonthlyStats(DateTime month) async {
    return await dbHelper.getMonthlyStats(month);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryStats(DateTime month) async {
    return await dbHelper.getCategoryStats(month);
  }
}

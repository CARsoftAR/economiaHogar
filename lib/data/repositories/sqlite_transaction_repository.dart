import '../../core/database/database_helper.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class SqliteTransactionRepository implements TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await dbHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
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
  Future<double> getTotalBalance() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(CASE WHEN isIncome = 1 THEN amount ELSE -amount END) as total FROM transactions');
    return result.first['total'] as double? ?? 0.0;
  }

  @override
  Future<Map<String, double>> getMonthlyStats(DateTime month) async {
    return await dbHelper.getMonthlyStats(month);
  }
}

import '../../core/database/database_helper.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class SqliteTransactionRepository implements TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  SqliteTransactionRepository();

  @override
  Future<List<TransactionModel>> getAllTransactions({DateTime? start, DateTime? end}) async {
    final db = await dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (start != null && end != null) {
      where = 'date >= ? AND date <= ?';
      whereArgs = [start.toIso8601String(), end.toIso8601String()];
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
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
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
  Future<Map<String, double>> getStatsByRange(DateTime start, DateTime end) async {
    return await dbHelper.getStatsByRange(start, end);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryStatsByRange(DateTime start, DateTime end) async {
    return await dbHelper.getCategoryStatsByRange(start, end);
  }

  @override
  Future<double> getMonthlyLimit() async {
    final limitStr = await dbHelper.getSetting('monthly_limit');
    return double.tryParse(limitStr ?? '100000') ?? 100000.0;
  }

  @override
  Future<void> updateMonthlyLimit(double limit) async {
    await dbHelper.updateSetting('monthly_limit', limit.toString());
  }
}

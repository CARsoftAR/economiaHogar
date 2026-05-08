import '../../data/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions({DateTime? month});
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getBalance();
  Future<Map<String, double>> getMonthlyStats(DateTime month);
  Future<List<Map<String, dynamic>>> getCategoryStats(DateTime month);
}

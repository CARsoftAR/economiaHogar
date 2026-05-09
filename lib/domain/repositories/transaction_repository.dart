import '../../data/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions({DateTime? start, DateTime? end});
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getBalance();
  Future<Map<String, double>> getStatsByRange(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getCategoryStatsByRange(DateTime start, DateTime end);
  Future<double> getMonthlyLimit();
  Future<void> updateMonthlyLimit(double limit);
}

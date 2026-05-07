import '../../data/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getTotalBalance();
  Future<Map<String, double>> getMonthlyStats(DateTime month);
}

import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository repository;
  List<TransactionModel> _transactions = [];
  double _balance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  List<Map<String, dynamic>> _categoryStats = [];
  bool _isLoading = false;

  TransactionProvider({required this.repository});

  List<TransactionModel> get transactions => _transactions;
  double get balance => _balance;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  List<Map<String, dynamic>> get categoryStats => _categoryStats;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    // Seed mock data for first run
    final dbHelper = (repository as dynamic).dbHelper; // Quick access for demo
    await dbHelper.seedMockData();
    
    _transactions = await repository.getAllTransactions();
    _balance = await repository.getTotalBalance();
    
    final now = DateTime.now();
    final stats = await repository.getMonthlyStats(now);
    _monthlyIncome = stats['income'] ?? 0.0;
    _monthlyExpense = stats['expense'] ?? 0.0;
    
    _categoryStats = await dbHelper.getCategoryStats(now);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await repository.addTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id);
    await fetchTransactions();
  }
}

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
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  TransactionProvider({required this.repository});

  List<TransactionModel> get transactions => _transactions;
  double get balance => _balance;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  List<Map<String, dynamic>> get categoryStats => _categoryStats;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    _transactions = await repository.getAllTransactions(month: _selectedMonth);
    _balance = await repository.getBalance();
    
    final stats = await repository.getMonthlyStats(_selectedMonth);
    _monthlyIncome = stats['income'] ?? 0.0;
    _monthlyExpense = stats['expense'] ?? 0.0;
    
    _categoryStats = await repository.getCategoryStats(_selectedMonth);
    
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

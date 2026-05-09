import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

enum PeriodType { hoy, semana, mes }

class TransactionProvider with ChangeNotifier {
  final TransactionRepository repository;
  List<TransactionModel> _transactions = [];
  double _balance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  double _monthlyLimit = 100000.0;
  List<Map<String, dynamic>> _categoryStats = [];
  DateTime _selectedMonth = DateTime.now();
  PeriodType _selectedPeriod = PeriodType.mes;
  bool? _selectedTypeFilter; // null = todos, true = ingresos, false = gastos
  bool _isLoading = false;

  TransactionProvider({required this.repository});

  List<TransactionModel> get transactions {
    if (_selectedTypeFilter == null) return _transactions;
    return _transactions.where((tx) => tx.isIncome == _selectedTypeFilter).toList();
  }
  double get balance => _balance;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get monthlyLimit => _monthlyLimit;
  List<Map<String, dynamic>> get categoryStats => _categoryStats;
  DateTime get selectedMonth => _selectedMonth;
  PeriodType get selectedPeriod => _selectedPeriod;
  bool? get selectedTypeFilter => _selectedTypeFilter;
  bool get isLoading => _isLoading;

  // NUEVO: Obtener estadísticas por día para el gráfico de líneas
  List<Map<String, dynamic>> get dailyStats {
    final Map<int, double> dailyMap = {};
    
    for (var tx in _transactions) {
      if (!tx.isIncome) {
        final day = tx.date.day;
        dailyMap[day] = (dailyMap[day] ?? 0.0) + tx.amount;
      }
    }
    
    // Convertir a lista ordenada por día
    final List<Map<String, dynamic>> result = [];
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    
    for (int i = 1; i <= lastDay; i++) {
      result.add({
        'day': i,
        'amount': dailyMap[i] ?? 0.0,
      });
    }
    return result;
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    fetchTransactions();
  }

  void setSelectedPeriod(PeriodType period) {
    _selectedPeriod = period;
    fetchTransactions();
  }

  void setSelectedTypeFilter(bool? isIncome) {
    _selectedTypeFilter = isIncome;
    notifyListeners();
  }

  Future<void> updateMonthlyLimit(double limit) async {
    await repository.updateMonthlyLimit(limit);
    _monthlyLimit = limit;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case PeriodType.hoy:
        start = DateTime(now.year, now.month, now.day);
        break;
      case PeriodType.semana:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case PeriodType.mes:
        start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
        break;
    }
    
    _transactions = await repository.getAllTransactions(start: start, end: end);
    _balance = await repository.getBalance();
    _monthlyLimit = await repository.getMonthlyLimit();
    
    final stats = await repository.getStatsByRange(start, end);
    _monthlyIncome = stats['income'] ?? 0.0;
    _monthlyExpense = stats['expense'] ?? 0.0;
    
    _categoryStats = await repository.getCategoryStatsByRange(start, end);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await repository.addTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await repository.updateTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id);
    await fetchTransactions();
  }
}

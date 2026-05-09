import 'dart:convert';

class TransactionModel {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final bool isIncome;
  final String categoryId;

  TransactionModel({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.isIncome,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'categoryId': categoryId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      categoryId: map['categoryId'] ?? 'others',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? description,
    DateTime? date,
    bool? isIncome,
    String? categoryId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

import 'package:flutter/material.dart';

class ReminderModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String type; // 'Pago' o 'Cobro'
  final bool isCompleted;

  ReminderModel({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.type,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'type': type,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['due_date']),
      type: map['type'],
      isCompleted: map['is_completed'] == 1,
    );
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    String? type,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

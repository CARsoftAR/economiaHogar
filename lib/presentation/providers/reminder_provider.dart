import 'package:flutter/material.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderRepository repository;
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;

  ReminderProvider({required this.repository});

  List<ReminderModel> get reminders => _reminders;
  List<ReminderModel> get pendingReminders => _reminders.where((r) => !r.isCompleted).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchReminders() async {
    _isLoading = true;
    notifyListeners();
    _reminders = await repository.getAllReminders();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await repository.addReminder(reminder);
    await fetchReminders();
  }

  Future<void> markAsCompleted(ReminderModel reminder) async {
    final updated = reminder.copyWith(isCompleted: true);
    await repository.updateReminder(updated);
    await fetchReminders();
  }

  Future<void> deleteReminder(int id) async {
    await repository.deleteReminder(id);
    await fetchReminders();
  }
}

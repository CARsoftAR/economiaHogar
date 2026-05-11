import 'package:flutter/material.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../core/services/notification_service.dart';
import 'package:intl/intl.dart';

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
    try {
      _reminders = await repository.getAllReminders();
    } catch (e) {
      debugPrint('Error cargando recordatorios: $e');
      // Podríamos agregar un estado de error si fuera necesario
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    final id = await repository.addReminder(reminder);
    
    // Agendar alarma sonora y visual para las 9:00 AM del día de vencimiento
    final scheduledDate = DateTime(
      reminder.dueDate.year,
      reminder.dueDate.month,
      reminder.dueDate.day,
      9, 0, 0, // 9:00 AM
    );

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2, locale: 'es_AR');

    await NotificationService().scheduleReminderNotification(
      id: id,
      title: '¡VENCIMIENTO HOY!',
      body: '${reminder.type}: ${reminder.title} por ${currencyFormat.format(reminder.amount)}',
      scheduledDate: scheduledDate,
    );

    await fetchReminders();
  }

  Future<void> markAsCompleted(ReminderModel reminder) async {
    final updated = reminder.copyWith(isCompleted: true);
    await repository.updateReminder(updated);
    
    // Cancelar la alarma si se marca como pagado
    if (reminder.id != null) {
      await NotificationService().cancelNotification(reminder.id!);
    }
    
    await fetchReminders();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await repository.updateReminder(reminder);
    
    // Si se actualizó la fecha o el monto, refrescar la alarma
    if (reminder.id != null && !reminder.isCompleted) {
      await NotificationService().cancelNotification(reminder.id!);
      
      final scheduledDate = DateTime(
        reminder.dueDate.year,
        reminder.dueDate.month,
        reminder.dueDate.day,
        9, 0, 0,
      );
      
      final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2, locale: 'es_AR');
      
      await NotificationService().scheduleReminderNotification(
        id: reminder.id!,
        title: '¡VENCIMIENTO HOY!',
        body: '${reminder.type}: ${reminder.title} por ${currencyFormat.format(reminder.amount)}',
        scheduledDate: scheduledDate,
      );
    }
    
    await fetchReminders();
  }

  Future<void> deleteReminder(int id) async {
    await repository.deleteReminder(id);
    await NotificationService().cancelNotification(id);
    await fetchReminders();
  }
}

import '../../data/models/reminder_model.dart';
import '../../core/database/database_helper.dart';

abstract class ReminderRepository {
  Future<List<ReminderModel>> getAllReminders();
  Future<int> addReminder(ReminderModel reminder);
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(int id);
}

class SqliteReminderRepository implements ReminderRepository {
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('reminders', orderBy: 'due_date ASC');
      return result.map((json) => ReminderModel.fromMap(json)).toList();
    } catch (e) {
      print('DEBUG: Error querying reminders table: $e');
      return []; // Retornar lista vacía para evitar bucles de carga
    }
  }

  @override
  Future<int> addReminder(ReminderModel reminder) async {
    final db = await dbHelper.database;
    return await db.insert('reminders', reminder.toMap());
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await dbHelper.database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  @override
  Future<void> deleteReminder(int id) async {
    final db = await dbHelper.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}

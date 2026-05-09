import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/reminder_provider.dart';
import '../providers/transaction_provider.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/transaction_model.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2, locale: 'es_AR');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'AGENDA DE PAGOS',
          style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.1),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBackgroundShape(const Color(0xFFE0E0E0).withOpacity(0.15), 350),
          ),
          SafeArea(
            child: Consumer<ReminderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF0000)));
                }

                if (provider.reminders.isEmpty) {
                  return const Center(
                    child: Text('No tienes pagos pendientes. ¡Buen trabajo!', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 120), // ESPACIO PARA LA BARRA
                  itemCount: provider.reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = provider.reminders[index];
                    return _buildReminderCard(context, reminder, currencyFormat);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showAddReminderModal(context),
          backgroundColor: const Color(0xFFFF0000),
          elevation: 12,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder, NumberFormat format) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(reminder.dueDate.year, reminder.dueDate.month, reminder.dueDate.day);
    final diff = dueDate.difference(today).inDays;

    Color statusColor = Colors.grey;
    bool isUrgent = false;

    if (reminder.isCompleted) {
      statusColor = Colors.green;
    } else if (diff <= 0) {
      statusColor = const Color(0xFFFF0000); // Vencido o vence hoy
      isUrgent = true;
    } else if (diff <= 3) {
      statusColor = Colors.orange; // Próximo
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: _buildGlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF2D3436),
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reminder.type} • ${DateFormat('dd MMM yyyy', 'es_AR').format(reminder.dueDate)}',
                    style: TextStyle(color: isUrgent ? const Color(0xFFFF0000) : Colors.grey[600], fontSize: 12, fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  format.format(reminder.amount),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isUrgent ? const Color(0xFFFF0000) : const Color(0xFF2D3436)),
                ),
                if (!reminder.isCompleted)
                  TextButton(
                    onPressed: () => _handleComplete(context, reminder),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                    child: const Text('PAGADO', style: TextStyle(color: Color(0xFFFF0000), fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleComplete(BuildContext context, ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Confirmar pago?'),
        content: const Text('¿Deseas registrar también este movimiento en tu Dashboard automáticamente?'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ReminderProvider>().markAsCompleted(reminder);
              Navigator.pop(dialogContext);
            },
            child: const Text('SÓLO COMPLETAR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Generar movimiento
              final newTransaction = TransactionModel(
                amount: reminder.amount,
                description: 'Pago: ${reminder.title}',
                date: DateTime.now(),
                isIncome: reminder.type == 'Cobro',
                categoryId: 'others',
              );
              context.read<TransactionProvider>().addTransaction(newTransaction);
              context.read<ReminderProvider>().markAsCompleted(reminder);
              Navigator.pop(dialogContext);
            },
            child: const Text('REGISTRAR Y COMPLETAR', style: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddReminderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderModal(),
    );
  }

  Widget _buildBackgroundShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AddReminderModal extends StatefulWidget {
  const AddReminderModal({super.key});

  @override
  State<AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<AddReminderModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'Pago';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25, left: 25, right: 25, bottom: MediaQuery.of(context).viewInsets.bottom + 25),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NUEVO RECORDATORIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Título del Recordatorio',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto',
              prefixText: '\$ ',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTypeButton('Pago', _type == 'Pago', () => setState(() => _type = 'Pago'))),
              const SizedBox(width: 15),
              Expanded(child: _buildTypeButton('Cobro', _type == 'Cobro', () => setState(() => _type = 'Cobro'))),
            ],
          ),
          const SizedBox(height: 25),
          const Text('Fecha de Vencimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd / MM / yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFFF0000)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
              child: const Text('GUARDAR RECORDATORIO', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFFF0000) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600])),
      ),
    );
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final newReminder = ReminderModel(
      title: _titleController.text,
      amount: amount,
      dueDate: _selectedDate,
      type: _type,
    );

    context.read<ReminderProvider>().addReminder(newReminder);
    Navigator.pop(context);
  }
}

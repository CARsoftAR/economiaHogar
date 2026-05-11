import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/reminder_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/fade_in_slide.dart';

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

                final reminders = provider.pendingReminders;

                if (reminders.isEmpty) {
                  return const Center(
                    child: Text('No tienes pagos pendientes. ¡Buen trabajo!', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 120),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: 100 + (index * 100)),
                      child: _buildReminderCard(context, reminder, currencyFormat),
                    );
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
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAddReminderModal(context);
          },
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

    String statusText = 'PENDIENTE';
    Color statusColor = Colors.grey;
    bool isUrgent = false;

    if (reminder.isCompleted) {
      statusText = 'PAGADO';
      statusColor = Colors.green;
    } else if (diff < 0) {
      statusText = 'VENCIDO';
      statusColor = const Color(0xFFFF0000);
      isUrgent = true;
    } else if (diff == 0) {
      statusText = 'VENCE HOY';
      statusColor = const Color(0xFFFF0000);
      isUrgent = true;
    } else if (diff <= 3) {
      statusText = 'POR VENCER';
      statusColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showReminderOptions(context, reminder);
        },
        onLongPress: () {
          HapticFeedback.vibrate();
          _showReminderOptions(context, reminder);
        },
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
                  const SizedBox(height: 5),
                  Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderOptions(BuildContext context, ReminderModel reminder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 25),
            const Text('OPCIONES DE AGENDA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 25),
            if (!reminder.isCompleted) ...[
              _buildOptionItem(
                icon: Icons.check_circle_rounded,
                label: 'Marcar como Pagado',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _handleComplete(context, reminder);
                },
              ),
              const SizedBox(height: 12),
            ],
            _buildOptionItem(
              icon: Icons.edit_note_rounded,
              label: 'Editar Recordatorio',
              color: const Color(0xFF0984E3),
              onTap: () {
                Navigator.pop(context);
                _showAddReminderModal(context, reminder: reminder);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionItem(
              icon: Icons.delete_sweep_rounded,
              label: 'Borrar Permanentemente',
              color: const Color(0xFFFF0000),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, reminder);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 15),
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Borrar recordatorio?'),
        content: Text('¿Estás seguro de que deseas eliminar "${reminder.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              context.read<ReminderProvider>().deleteReminder(reminder.id!);
              Navigator.pop(context);
            },
            child: const Text('BORRAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleComplete(BuildContext context, ReminderModel reminder) {
    // Capturamos los providers antes de abrir el diálogo para asegurar consistencia
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        title: const Text(
          '¿Confirmar pago?',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Deseas registrar también este movimiento en tu Dashboard automáticamente?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  // Registrar en transacciones
                  final newTransaction = TransactionModel(
                    amount: reminder.amount,
                    description: '${reminder.type}: ${reminder.title}',
                    date: DateTime.now(),
                    isIncome: reminder.type == 'Cobro',
                    categoryId: reminder.categoryId,
                  );
                  await transactionProvider.addTransaction(newTransaction);
                  // Marcar como completado
                  await reminderProvider.markAsCompleted(reminder);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('REGISTRAR Y COMPLETAR', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await reminderProvider.markAsCompleted(reminder);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                child: const Text('SÓLO COMPLETAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderModal(BuildContext context, {ReminderModel? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderModal(reminder: reminder),
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
  final ReminderModel? reminder;
  const AddReminderModal({super.key, this.reminder});

  @override
  State<AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<AddReminderModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'Pago';
  String _selectedCategoryId = 'others';

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _amountController.text = widget.reminder!.amount.toString();
      _selectedDate = widget.reminder!.dueDate;
      _type = widget.reminder!.type;
      _selectedCategoryId = widget.reminder!.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25, left: 25, right: 25, bottom: MediaQuery.of(context).viewInsets.bottom + 25),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.reminder != null ? 'EDITAR RECORDATORIO' : 'NUEVO RECORDATORIO',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))
                ),
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
                HapticFeedback.selectionClick();
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
            const SizedBox(height: 25),
            const Text('Categoría para el Movimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _saveReminder();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                child: Text(
                  widget.reminder != null ? 'ACTUALIZAR RECORDATORIO' : 'GUARDAR RECORDATORIO',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        // Mostramos todas las categorías sin filtrar por tipo, como pidió el usuario
        final allCategories = provider.categories;
        
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allCategories.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategoryId = cat.id);
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 80) / 4, // 4 columnas
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected ? cat.color.withOpacity(0.1) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(15),
                  border: isSelected ? Border.all(color: cat.color, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, color: isSelected ? cat.color : Colors.grey, size: 22),
                    const SizedBox(height: 5),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 9, 
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                        color: isSelected ? cat.color : Colors.grey
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
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

    if (widget.reminder != null) {
      // Editar existente
      final updatedReminder = widget.reminder!.copyWith(
        title: _titleController.text,
        amount: amount,
        dueDate: _selectedDate,
        type: _type,
        categoryId: _selectedCategoryId,
      );
      context.read<ReminderProvider>().updateReminder(updatedReminder);
    } else {
      // Crear nuevo
      final newReminder = ReminderModel(
        title: _titleController.text,
        amount: amount,
        dueDate: _selectedDate,
        type: _type,
        categoryId: _selectedCategoryId,
      );
      context.read<ReminderProvider>().addReminder(newReminder);
    }
    Navigator.pop(context);
  }
}

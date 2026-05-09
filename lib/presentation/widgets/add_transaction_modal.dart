import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';

class AddTransactionModal extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionModal({super.key, this.transaction});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isIncome = false;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _descriptionController.text = tx.description;
      _isIncome = tx.isIncome;
      _selectedCategoryId = tx.categoryId;
      _selectedDate = tx.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;

        return Container(
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.transaction == null ? 'NUEVO MOVIMIENTO' : 'EDITAR MOVIMIENTO',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Selector de flujo
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton('Gasto', !_isIncome, () => setState(() => _isIncome = false), const Color(0xFFFF0000)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTypeButton('Ingreso', _isIncome, () => setState(() => _isIncome = true), const Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  // Monto Principal
                  const Text('Monto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436), fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      border: InputBorder.none,
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción (opcional)',
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Selector de Categoría (TODAS)
                  const Text('Seleccionar Categoría', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436), fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: categories.isEmpty
                      ? const Center(child: Text('No hay categorías creadas', style: TextStyle(color: Colors.grey, fontSize: 12)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = _selectedCategoryId == cat.id;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedCategoryId = cat.id;
                                  _isIncome = cat.isIncome; // Auto-cambiar el tipo según la categoría
                                });
                              },
                              child: Container(
                                width: 85,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? cat.color.withOpacity(0.1) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelected ? Border.all(color: cat.color, width: 2) : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(cat.icon, color: isSelected ? cat.color : Colors.grey, size: 24),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        cat.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? cat.color : Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      cat.isIncome ? 'Ingreso' : 'Egreso',
                                      style: TextStyle(fontSize: 8, color: Colors.grey[400]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isIncome ? const Color(0xFF2E7D32) : const Color(0xFFFF0000),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.transaction == null ? 'CONFIRMAR MOVIMIENTO' : 'GUARDAR CAMBIOS', 
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap, Color activeColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? null : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _submitData() {
    HapticFeedback.mediumImpact();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) return;

    if (widget.transaction == null) {
      final newTransaction = TransactionModel(
        amount: amount,
        description: _descriptionController.text,
        date: _selectedDate,
        isIncome: _isIncome,
        categoryId: _selectedCategoryId!,
      );
      context.read<TransactionProvider>().addTransaction(newTransaction);
    } else {
      final updatedTransaction = widget.transaction!.copyWith(
        amount: amount,
        description: _descriptionController.text,
        date: _selectedDate,
        isIncome: _isIncome,
        categoryId: _selectedCategoryId!,
      );
      context.read<TransactionProvider>().updateTransaction(updatedTransaction);
    }
    
    Navigator.pop(context);
  }
}

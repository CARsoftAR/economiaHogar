import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = false;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setInitialCategory();
  }

  void _setInitialCategory() {
    _selectedCategoryId = CategoryModel.categories
        .firstWhere((c) => c.isIncome == _isIncome)
        .id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryRed),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null) return;
    setState(() => _selectedDate = pickedDate);
  }

  void _submitData() {
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0 || _selectedCategoryId == null) return;

    final newTransaction = TransactionModel(
      amount: enteredAmount,
      description: _descriptionController.text,
      date: _selectedDate,
      isIncome: _isIncome,
      categoryId: _selectedCategoryId!,
    );

    context.read<TransactionProvider>().addTransaction(newTransaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = CategoryModel.categories.where((c) => c.isIncome == _isIncome).toList();
    final accentColor = _isIncome ? Colors.green[600]! : AppTheme.primaryRed;
    final softBgColor = _isIncome ? Colors.green[50]! : Colors.red[50]!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: softBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nuevo Movimiento',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTypeTab('Gasto', !_isIncome, Colors.red, () {
                          setState(() {
                            _isIncome = false;
                            _setInitialCategory();
                          });
                        }),
                        const SizedBox(width: 10),
                        _buildTypeTab('Ingreso', _isIncome, Colors.green, () {
                          setState(() {
                            _isIncome = true;
                            _setInitialCategory();
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(25),
                  children: [
                    // Amount Field
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: accentColor),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '\$ ',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: accentColor.withOpacity(0.3)),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Category Grid
                    const Text('Selecciona una Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final cat = filteredCategories[index];
                        final isSelected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? cat.color : cat.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: isSelected 
                                      ? Border.all(color: Colors.white, width: 2)
                                      : null,
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: isSelected ? Colors.white : cat.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? cat.color : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    
                    // Date & Description
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputCard(
                            icon: Icons.calendar_today,
                            label: 'Fecha',
                            value: DateFormat('dd/MM/yy').format(_selectedDate),
                            onTap: _presentDatePicker,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildInputCard(
                            icon: Icons.description,
                            label: 'Nota',
                            value: _descriptionController.text.isEmpty ? 'Añadir' : 'Editar',
                            onTap: () => _showDescriptionDialog(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Confirmar Movimiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, bool isSelected, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        blur: 5,
        opacity: 0.05,
        borderRadius: 15,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Nota'),
        content: TextField(
          controller: _descriptionController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ej. Compra semanal'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    ).then((_) => setState(() {}));
  }
}

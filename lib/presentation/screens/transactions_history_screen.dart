import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/add_transaction_modal.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;
  bool? _isIncomeFilter; // null = todos, true = ingresos, false = gastos

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2, locale: 'es_AR');
    final categoryProvider = context.read<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3436), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HISTORIAL COMPLETO',
          style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA Y FILTROS
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 15),
                _buildQuickFilters(),
              ],
            ),
          ),
          
          // LISTA DE RESULTADOS
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final filteredList = provider.transactions.where((tx) {
                  final matchesQuery = tx.description.toLowerCase().contains(_query.toLowerCase()) ||
                      categoryProvider.getCategoryById(tx.categoryId).name.toLowerCase().contains(_query.toLowerCase());
                  
                  final matchesType = _isIncomeFilter == null || tx.isIncome == _isIncomeFilter;
                  final matchesCategory = _selectedCategoryId == null || tx.categoryId == _selectedCategoryId;
                  
                  return matchesQuery && matchesType && matchesCategory;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 15),
                        Text('No se encontraron movimientos', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final tx = filteredList[index];
                    final category = categoryProvider.getCategoryById(tx.categoryId);
                    return FadeInSlide(
                      delay: Duration(milliseconds: index * 30),
                      child: _buildHistoryItem(context, tx, category, currencyFormat),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _query = val),
        decoration: InputDecoration(
          hintText: 'Buscar por descripción o categoría...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          suffixIcon: _query.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18), 
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  }
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Todos', _isIncomeFilter == null, () => setState(() => _isIncomeFilter = null)),
          const SizedBox(width: 8),
          _buildFilterChip('Ingresos', _isIncomeFilter == true, () => setState(() => _isIncomeFilter = true)),
          const SizedBox(width: 8),
          _buildFilterChip('Gastos', _isIncomeFilter == false, () => setState(() => _isIncomeFilter = false)),
          const SizedBox(width: 15),
          const VerticalDivider(width: 1, color: Colors.grey),
          const SizedBox(width: 15),
          // Aquí podríamos poner un selector de categorías si el usuario tiene muchas
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF0000) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TransactionModel tx, CategoryModel category, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showTransactionOptions(context, tx);
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: category.color.withOpacity(0.1),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3436))),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('dd MMM, yyyy').format(tx.date)} • ${tx.description.isEmpty ? 'Sin descripción' : tx.description}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${tx.isIncome ? '+' : '-'}${format.format(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: tx.isIncome ? const Color(0xFF2E7D32) : const Color(0xFFFF0000),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, TransactionModel tx) {
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text('OPCIONES DE MOVIMIENTO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 25),
            _buildOptionItem(
              icon: Icons.edit_note_rounded,
              label: 'Editar Movimiento',
              color: const Color(0xFF0984E3),
              onTap: () {
                Navigator.pop(context);
                _showAddTransaction(context, tx);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionItem(
              icon: Icons.delete_sweep_rounded,
              label: 'Eliminar Permanente',
              color: const Color(0xFFFF0000),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTransaction(context, tx);
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
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
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

  void _showAddTransaction(BuildContext context, [TransactionModel? tx]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(transaction: tx),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar Movimiento?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Esta acción quitará el monto de tu saldo y no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(tx.id!);
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

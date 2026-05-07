import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_modal.dart';
import '../../core/widgets/glass_container.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

import '../widgets/trend_line_chart.dart';

import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TransactionProvider>().fetchTransactions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pro Currency Format: $3.000,00
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_AR',
    );
    final dateFormat = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header / Floating Glass Card with Trend
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 20),
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: GlassContainer(
                      blur: 20,
                      opacity: 0.1,
                      borderRadius: 35,
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Text(
                            'SALDO TOTAL',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const TrendLineChart(),
                              Text(
                                currencyFormat.format(provider.balance),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'INGRESOS',
                                  provider.monthlyIncome,
                                  const Color(0xFF43A047),
                                  Icons.arrow_upward_rounded,
                                  currencyFormat,
                                ),
                              ),
                              Container(width: 1, height: 30, color: Colors.grey[200]),
                              Expanded(
                                child: _buildStatItem(
                                  'GASTOS',
                                  provider.monthlyExpense,
                                  AppTheme.primaryRed,
                                  Icons.arrow_downward_rounded,
                                  currencyFormat,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Category Summary
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
              child: Text(
                'Gasto por Categoría',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final topCategories = provider.categoryStats.take(4).toList();
                
                if (topCategories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: topCategories.length,
                    itemBuilder: (context, index) {
                      final stat = topCategories[index];
                      final category = CategoryModel.getById(stat['categoryId']);
                      final amount = stat['total'] as double;
                      final progress = (amount / (provider.monthlyIncome > 0 ? provider.monthlyIncome : 100000)).clamp(0.1, 0.9);

                      return GlassContainer(
                        blur: 5,
                        opacity: 0.05,
                        borderRadius: 15,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(category.icon, size: 16, color: category.color),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currencyFormat.format(amount).split(',')[0],
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                color: category.color,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Transactions List Label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Movimientos Recientes',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.w800, 
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Ver todos', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),

          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = provider.transactions[index];
                    final category = CategoryModel.getById(tx.categoryId);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: GestureDetector(
                        onTap: () => _showTransactionDetail(tx, category),
                        onLongPress: () {
                          HapticFeedback.heavyImpact();
                          _showDeleteConfirm(tx.id!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: GlassContainer(
                            blur: 10,
                            opacity: 0.02,
                            borderRadius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(category.icon, color: category.color, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                      Text(
                                        tx.description.isEmpty ? 'Sin descripción' : tx.description,
                                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${tx.isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: tx.isIncome ? const Color(0xFF2E7D32) : AppTheme.primaryRed,
                                      ),
                                    ),
                                    Text(
                                      dateFormat.format(tx.date),
                                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: provider.transactions.length,
                ),
              );
            },
          ),
          
          // BOTTOM PADDING for FAB visibility
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTransaction(context),
          label: const Text('NUEVO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          icon: const Icon(Icons.add_rounded, size: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showTransactionDetail(TransactionModel tx, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 10),
            Text(category.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(tx.date)}'),
            const SizedBox(height: 10),
            const Text('Nota:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(tx.description.isEmpty ? 'Sin nota adicional' : tx.description),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar movimiento?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Movimiento eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color, IconData icon, NumberFormat format) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          format.format(value),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }
}

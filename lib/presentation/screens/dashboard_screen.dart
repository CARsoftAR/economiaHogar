import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/add_transaction_modal.dart';
import 'reports_screen.dart';
import 'categories_screen.dart';
import 'reminders_screen.dart';
import '../widgets/edit_budget_modal.dart';
import '../widgets/fade_in_slide.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

import '../widgets/trend_line_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
      context.read<TransactionProvider>().fetchTransactions();
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_AR',
    );
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: _buildBackgroundShape(const Color(0xFFFFCDD2).withOpacity(0.15), 320),
          ),
          Positioned(
            bottom: 120,
            left: -50,
            child: _buildBackgroundShape(const Color(0xFFE0E0E0).withOpacity(0.2), 280),
          ),
          
          SafeArea(
            child: Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, provider, categoryProvider, child) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      
                      const SizedBox(height: 15),
                      
                      // CONTENEDOR PRINCIPAL BLANCO
                      FadeInSlide(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 1. BLOQUE DE SALDO PRINCIPAL
                            Column(
                              children: [
                                const Text(
                                  'SALDO ACTUAL',
                                  style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyFormat.format(provider.balance),
                                  style: const TextStyle(
                                    color: Color(0xFF0984E3), // Azul Vibrante
                                    fontSize: 36, 
                                    fontWeight: FontWeight.w900, 
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // 2. FILA DE RESUMEN (INGRESOS/GASTOS)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryBox('INGRESOS', provider.monthlyIncome, const Color(0xFF2E7D32), currencyFormat),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildSummaryBox('GASTOS', provider.monthlyExpense, const Color(0xFFFF0000), currencyFormat),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // 3. INDICADOR DE PRESUPUESTO CIRCULAR
                            _buildCircularBudget(provider),
                            
                            const SizedBox(height: 30),
                            
                            // 4. BOTONES DE FILTRO
                            _buildPillFilters(provider),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                      const FadeInSlide(
                        delay: Duration(milliseconds: 400),
                        child: Text('Gasto por Categoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
                      ),
                      const SizedBox(height: 15),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: provider.categoryStats.take(4).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final stat = entry.value;
                          final category = categoryProvider.getCategoryById(stat['categoryId']);
                          final amount = stat['total'] as double;
                          final progress = (amount / (provider.monthlyIncome > 0 ? provider.monthlyIncome : 100000)).clamp(0.05, 1.0);
                          
                          return FadeInSlide(
                            delay: Duration(milliseconds: 500 + (index * 100)),
                            child: SizedBox(
                              width: (MediaQuery.of(context).size.width - 52) / 2,
                              child: _buildCategoryStatCard(category, amount, progress, currencyFormat),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Movimientos Recientes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Ver todos', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF0000))),
                          ),
                        ],
                      ),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.transactions.take(5).length,
                        itemBuilder: (context, index) {
                          final tx = provider.transactions[index];
                          final category = categoryProvider.getCategoryById(tx.categoryId);
                          return FadeInSlide(
                            delay: Duration(milliseconds: 700 + (index * 100)),
                            child: _buildTransactionItem(tx, category, currencyFormat),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 120), // ESPACIO PARA NO QUEDAR DETRÁS DE LA BARRA
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // SUBIR EL BOTÓN PARA QUE NO SE TAPE
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAddTransaction(context);
          },
          label: const Text('NUEVO', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          backgroundColor: const Color(0xFFFF0000),
          elevation: 12, // MÁS ELEVACIÓN PARA QUE FLOTE SOBRE EL VIDRIO
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildBackgroundShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
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

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGlassCard(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: const Color(0xFFFF0000), size: 22),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color, NumberFormat format) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(format.format(value), style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildSummaryBox(String label, double amount, Color color, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(format.format(amount), style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildCircularBudget(TransactionProvider provider) {
    final double progress = (provider.monthlyExpense / provider.monthlyLimit).clamp(0.0, 1.0);
    final bool isOver = provider.monthlyExpense >= provider.monthlyLimit;
    
    Color statusColor = const Color(0xFF2E7D32);
    if (progress >= 0.9) statusColor = const Color(0xFFFF0000);
    else if (progress >= 0.7) statusColor = Colors.orange;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBudgetModal(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                ),
              ],
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOver ? '¡Límite alcanzado!' : 'Presupuesto saludable',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOver ? 'Has superado tu meta mensual' : 'Vas por buen camino este mes',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillFilters(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterPill('HOY', PeriodType.hoy, provider),
          _buildFilterPill('SEMANA', PeriodType.semana, provider),
          _buildFilterPill('MES', PeriodType.mes, provider),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx, CategoryModel category, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: _buildGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: category.color.withOpacity(0.1),
                child: Icon(category.icon, color: category.color, size: 18),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3436))),
                    Text(
                      tx.description.isEmpty ? 'Sin descripción' : tx.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildCategoryStatCard(CategoryModel category, double amount, double progress, NumberFormat format) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: _buildGlassCard(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, size: 16, color: category.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              format.format(amount).split(',')[0],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
            ),
            const SizedBox(height: 12),
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, PeriodType period, TransactionProvider provider) {
    final isSelected = provider.selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          provider.setSelectedPeriod(period);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF0000) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
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

  void _showBudgetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditBudgetModal(),
    );
  }
}

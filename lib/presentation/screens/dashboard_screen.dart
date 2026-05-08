import 'package:flutter/material.dart';
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
      drawer: _buildDrawer(context),
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
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Builder(
                                builder: (context) => _buildGlassIconButton(
                                  icon: Icons.menu_rounded,
                                  onTap: () => Scaffold.of(context).openDrawer(),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy', 'es_AR').format(provider.selectedMonth).toUpperCase(),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                                  ),
                                  const Text('Resumen Mensual', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildGlassIconButton(
                                icon: Icons.notifications_none_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RemindersScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildGlassIconButton(
                                icon: Icons.bar_chart_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      _buildGlassCard(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: [
                            const Text(
                              'SALDO ACTUAL',
                              style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Opacity(opacity: 0.15, child: TrendLineChart()),
                                FittedBox(
                                  child: Text(
                                    currencyFormat.format(provider.balance),
                                    style: const TextStyle(color: Color(0xFF2D3436), fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(child: _buildStatItem('INGRESOS', provider.monthlyIncome, const Color(0xFF2E7D32), currencyFormat)),
                                Container(width: 1, height: 35, color: Colors.black.withOpacity(0.05)),
                                Expanded(child: _buildStatItem('GASTOS', provider.monthlyExpense, const Color(0xFFFF0000), currencyFormat)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 35),
                      const Text('Gasto por Categoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
                      const SizedBox(height: 15),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: provider.categoryStats.take(4).map((stat) {
                          final category = categoryProvider.getCategoryById(stat['categoryId']);
                          final amount = stat['total'] as double;
                          final progress = (amount / (provider.monthlyIncome > 0 ? provider.monthlyIncome : 100000)).clamp(0.05, 1.0);
                          
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 52) / 2,
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
                                    currencyFormat.format(amount).split(',')[0],
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
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = provider.transactions[index];
                          final category = categoryProvider.getCategoryById(tx.categoryId);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                                    '${tx.isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: tx.isIncome ? const Color(0xFF2E7D32) : const Color(0xFFFF0000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransaction(context),
        label: const Text('NUEVO', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        backgroundColor: const Color(0xFFFF0000),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ECONOMÍA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFFF0000))),
                Text('HOGAR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.category_rounded,
            title: 'Categorías',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications_none_rounded,
            title: 'Agenda de Pagos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_rounded,
            title: 'Reportes',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(25),
            child: Text('Versión 1.3.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2D3436)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    );
  }
}

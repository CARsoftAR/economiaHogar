import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_AR',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Quitar botón de retroceso
        title: const Text(
          'REPORTES',
          style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: _buildBackgroundShape(const Color(0xFFFFCDD2).withOpacity(0.1), 300),
          ),
          SafeArea(
            child: Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, provider, categoryProvider, child) {
                final stats = provider.categoryStats;
                final totalExpenses = provider.monthlyExpense;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Distribución de Gastos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat('MMMM yyyy', 'es_AR').format(provider.selectedMonth).toUpperCase(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      
                      _buildGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 250,
                              child: stats.isEmpty 
                                ? const Center(child: Text('Sin datos para graficar'))
                                : PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 50,
                                      sections: stats.map((stat) {
                                        final category = categoryProvider.getCategoryById(stat['categoryId']);
                                        final amount = stat['total'] as double;
                                        final percentage = (amount / totalExpenses * 100);
                                        
                                        return PieChartSectionData(
                                          color: category.color,
                                          value: amount,
                                          title: '${percentage.toStringAsFixed(0)}%',
                                          radius: 60,
                                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                            ),
                            if (stats.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Total Gastado: ${currencyFormat.format(totalExpenses)}',
                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      const Text('Desglose por Categoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
                      const SizedBox(height: 15),
                      
                      if (stats.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text('No hay gastos registrados para este periodo', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        )
                      else
                        ...stats.map((stat) {
                          final category = categoryProvider.getCategoryById(stat['categoryId']);
                          final amount = stat['total'] as double;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildGlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: category.color.withOpacity(0.1),
                                    child: Icon(category.icon, color: category.color, size: 20),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))),
                                  ),
                                  Text(currencyFormat.format(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D3436))),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 120), // ESPACIO PARA LA BARRA
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

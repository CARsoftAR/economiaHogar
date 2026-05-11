import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/reminder_provider.dart';
import '../../core/services/backup_service.dart';
import '../widgets/edit_budget_modal.dart';
import '../widgets/fade_in_slide.dart';
import '../../core/database/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FadeInSlide(
                duration: Duration(milliseconds: 800),
                child: Text(
                  'CONFIGURACIÓN',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF2D3436)),
                ),
              ),
              const SizedBox(height: 30),
              
              const FadeInSlide(
                delay: Duration(milliseconds: 200),
                child: Text(
                  'FINANZAS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 15),
              
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _buildSettingsCard(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Presupuesto Mensual',
                  subtitle: 'Ajusta tu límite de gasto',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const EditBudgetModal(),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              
              const FadeInSlide(
                delay: Duration(milliseconds: 400),
                child: Text(
                  'DATOS Y PRIVACIDAD',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 15),
              
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: _buildSettingsCard(
                  context,
                  icon: Icons.cloud_upload_rounded,
                  title: 'Exportar Copia de Seguridad',
                  subtitle: 'Guarda tus datos en Google Drive o archivos',
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    try {
                      await BackupService.exportBackup();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 15),
              
              FadeInSlide(
                delay: const Duration(milliseconds: 600),
                child: _buildSettingsCard(
                  context,
                  icon: Icons.cloud_download_rounded,
                  title: 'Restaurar Datos',
                  subtitle: 'Importar desde un archivo de respaldo',
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final success = await BackupService.importBackup();
                    if (success && context.mounted) {
                      await context.read<TransactionProvider>().fetchTransactions();
                      await context.read<CategoryProvider>().fetchCategories();
                      await context.read<ReminderProvider>().fetchReminders();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Datos restaurados correctamente')),
                        );
                      }
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 30),
              
              FadeInSlide(
                delay: const Duration(milliseconds: 700),
                child: _buildSettingsCard(
                  context,
                  icon: Icons.delete_forever_rounded,
                  title: 'Reiniciar Datos de Fábrica',
                  subtitle: 'Borra todos los movimientos y agenda',
                  onTap: () async {
                    HapticFeedback.vibrate();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Estás seguro?'),
                        content: const Text('Esto borrará todos tus movimientos y recordatorios de forma permanente. Las categorías se mantendrán.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            child: const Text('SÍ, BORRAR TODO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final db = DatabaseHelper.instance;
                      await db.clearAllData();
                      if (context.mounted) {
                        await context.read<TransactionProvider>().fetchTransactions();
                        await context.read<ReminderProvider>().fetchReminders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('La aplicación ha sido limpiada')),
                        );
                      }
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 100), // Espacio para el menú inferior
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: const Color(0xFFFF0000), size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

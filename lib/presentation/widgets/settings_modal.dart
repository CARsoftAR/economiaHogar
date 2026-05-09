import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/reminder_provider.dart';
import '../../core/services/backup_service.dart';
import 'edit_budget_modal.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AJUSTES',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436)),
              ),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSettingsItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Presupuesto Mensual',
            subtitle: 'Ajusta tu límite de gasto',
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const EditBudgetModal(),
              );
            },
          ),
          
          const Divider(height: 30),
          
          const Text(
            'DATOS Y PRIVACIDAD',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
          ),
          const SizedBox(height: 15),
          
          _buildSettingsItem(
            icon: Icons.cloud_upload_rounded,
            title: 'Exportar Copia de Seguridad',
            subtitle: 'Guarda tus datos en un archivo',
            onTap: () async {
              HapticFeedback.mediumImpact();
              try {
                await BackupService.exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copia de seguridad generada')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
          
          const SizedBox(height: 10),
          
          _buildSettingsItem(
            icon: Icons.cloud_download_rounded,
            title: 'Restaurar Datos',
            subtitle: 'Importar desde un archivo .db',
            onTap: () async {
              HapticFeedback.mediumImpact();
              final success = await BackupService.importBackup();
              if (success && context.mounted) {
                // Forzar recarga de datos
                await context.read<TransactionProvider>().fetchTransactions();
                await context.read<CategoryProvider>().fetchCategories();
                await context.read<ReminderProvider>().fetchReminders();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Datos restaurados correctamente')),
                  );
                  Navigator.pop(context);
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFF0000), size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3436))),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class EditBudgetModal extends StatefulWidget {
  const EditBudgetModal({super.key});

  @override
  State<EditBudgetModal> createState() => _EditBudgetModalState();
}

class _EditBudgetModalState extends State<EditBudgetModal> {
  final _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _limitController.text = context.read<TransactionProvider>().monthlyLimit.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 25, 
        left: 25, 
        right: 25, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 25
      ),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DEFINIR PRESUPUESTO', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))
              ),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Define cuánto planeas gastar como máximo cada mes.', 
            style: TextStyle(color: Colors.grey, fontSize: 13)
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Límite de Gasto Mensual',
              prefixText: '\$ ',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _saveBudget();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                'GUARDAR LÍMITE', 
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveBudget() {
    final limit = double.tryParse(_limitController.text) ?? 0;
    if (limit > 0) {
      context.read<TransactionProvider>().updateMonthlyLimit(limit);
      Navigator.pop(context);
    }
  }
}

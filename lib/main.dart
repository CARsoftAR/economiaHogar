import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/sqlite_transaction_repository.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            repository: SqliteTransactionRepository(),
          ),
        ),
      ],
      child: const EconomiaHogarApp(),
    ),
  );
}

class EconomiaHogarApp extends StatelessWidget {
  const EconomiaHogarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Economía del Hogar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}

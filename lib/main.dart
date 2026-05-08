import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/reminder_repository.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            repository: SqliteCategoryRepository(),
          )..fetchCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(
            repository: SqliteReminderRepository(),
          )..fetchReminders(),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'AR'),
      ],
      locale: const Locale('es', 'AR'),
      home: const DashboardScreen(),
    );
  }
}

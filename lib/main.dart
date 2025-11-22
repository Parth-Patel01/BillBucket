import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/bill.dart';
import 'models/app_settings.dart';
import 'providers/bill_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BillFrequencyAdapter());
  Hive.registerAdapter(BillAdapter());
  final billsBox = await Hive.openBox<Bill>('bills_box');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BillProvider(billsBox: billsBox),
        ),
      ],
      child: const BillBucketApp(),
    ),
  );
}

class BillBucketApp extends StatelessWidget {
  const BillBucketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Bucket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // later you can hook this to Settings
      home: const DashboardScreen(),
    );
  }
}

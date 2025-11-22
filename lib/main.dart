import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/bill.dart';
import 'models/app_settings.dart';
import 'providers/bill_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(BillFrequencyAdapter());
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Open boxes
  final billsBox = await Hive.openBox<Bill>('bills_box');
  final settingsBox = await Hive.openBox<AppSettings>('settings_box');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BillProvider(billsBox: billsBox),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsBox: settingsBox),
        ),
      ],
      child: const BillBucketApp(),
    ),
  );
}

/// Root widget of the app.
///
/// Listens to SettingsProvider to decide which theme mode to use.
class BillBucketApp extends StatelessWidget {
  const BillBucketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeMode = _mapAppThemeMode(settings.themeMode);

    return MaterialApp(
      title: 'Bill Bucket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }

  /// Maps our custom AppThemeMode enum to Flutter's ThemeMode.
  ThemeMode _mapAppThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

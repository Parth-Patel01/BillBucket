import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/bill.dart';
import 'providers/bill_provider.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  // Ensure Flutter engine is initialized before any async/Plugin calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter (uses app document directory).
  await Hive.initFlutter();

  // Register Hive adapters for our models.
  // These classes are generated in `bill.g.dart` via build_runner.
  Hive.registerAdapter(BillFrequencyAdapter());
  Hive.registerAdapter(BillAdapter());

  // Open the box that will store Bill objects.
  final billsBox = await Hive.openBox<Bill>('bills_box');

  runApp(BillBucketApp(billsBox: billsBox));
}

/// Root widget of the app.
///
/// Wraps MaterialApp with Provider so the entire app tree
/// has access to the BillProvider.
class BillBucketApp extends StatelessWidget {
  const BillBucketApp({
    super.key,
    required this.billsBox,
  });

  final Box<Bill> billsBox;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BillProvider>(
          create: (_) => BillProvider(billsBox: billsBox),
        ),
      ],
      child: MaterialApp(
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
        // Later we can add themeMode from settings; for now just system.
        themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      ),
    );
  }
}

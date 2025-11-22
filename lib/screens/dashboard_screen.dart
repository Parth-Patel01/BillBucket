import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bill_provider.dart';
import '../models/bill.dart';
import 'add_edit_bill_screen.dart';
import 'bill_detail_screen.dart';


/// Initial dashboard screen.
///
/// Right now it just:
/// - Reads data from BillProvider.
/// - Shows basic info to confirm that everything is wired correctly.
/// Later we will expand this into proper cards and lists.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final bills = billProvider.bills;
    final totalMonthly = billProvider.totalMonthlyCost;
    final weeklyTransfer = billProvider.recommendedWeeklyTransfer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Bucket Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditBillScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: billProvider.isInitialized
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCard(
              totalMonthly: totalMonthly,
              weeklyTransfer: weeklyTransfer,
            ),
            const SizedBox(height: 16),
            Text(
              'All Bills (${bills.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: bills.isEmpty
                  ? const Center(
                child: Text(
                  'No bills added yet.\nTap the + button to add your first bill.',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return _BillListTile(bill: bill);
                },
              ),
            ),
          ],
        )
            : const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Simple card showing summary metrics.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalMonthly,
    required this.weeklyTransfer,
  });

  final double totalMonthly;
  final double weeklyTransfer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SummaryItem(
              label: 'Monthly Cost',
              value: totalMonthly,
              textTheme: textTheme,
            ),
            _SummaryItem(
              label: 'Weekly Transfer',
              value: weeklyTransfer,
              textTheme: textTheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final double value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Basic list tile for a bill.
/// We’ll later navigate to a detailed screen when tapping it.
class _BillListTile extends StatelessWidget {
  const _BillListTile({
    required this.bill,
  });

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final freqLabel = Bill.frequencyLabel(bill.frequency);

    return Card(
      child: ListTile(
        title: Text(bill.name),
        subtitle: Text(
          '$freqLabel • Next due: '
              '${bill.nextDueDate.day}/${bill.nextDueDate.month}/${bill.nextDueDate.year}',
        ),
        trailing: Text('\$${bill.amount.toStringAsFixed(2)}'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BillDetailScreen(billId: bill.id),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bill_provider.dart';
import '../models/bill.dart';
import '../utils/formatters.dart';
import 'add_edit_bill_screen.dart';
import 'bill_detail_screen.dart';

/// Main dashboard screen.
///
/// Responsibilities:
/// - Shows high-level summary (monthly cost, recommended weekly transfer).
/// - Shows upcoming bills (next 14 days).
/// - Lists all bills sorted by next due date.
/// - Provides FAB to add a new bill.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final bills = billProvider.bills;
    final totalMonthly = billProvider.totalMonthlyCost;
    final weeklyTransfer = billProvider.recommendedWeeklyTransfer;
    final upcomingBills = billProvider.upcomingBills(daysAhead: 14);

    // 🔹 Sort main list by next due date (soonest first)
    final sortedBills = [...bills]
      ..sort(
            (a, b) => a.nextDueDate.compareTo(b.nextDueDate),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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

            _UpcomingBillsSection(upcomingBills: upcomingBills),
            const SizedBox(height: 16),

            Text(
              'All Bills (${sortedBills.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: sortedBills.isEmpty
                  ? const Center(
                child: Text(
                  'No bills added yet.\nTap the + button to add your first bill.',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 80,
                ), // extra space for FAB
                itemCount: sortedBills.length,
                itemBuilder: (context, index) {
                  final bill = sortedBills[index];
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

/// Simple card showing summary metrics (monthly cost and weekly transfer).
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
          formatMoney(value),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Card section for upcoming bills within the next 14 days.
/// Grows naturally but stops at a maximum height.
class _UpcomingBillsSection extends StatelessWidget {
  const _UpcomingBillsSection({
    required this.upcomingBills,
  });

  final List<Bill> upcomingBills;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final billProvider = context.read<BillProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming bills (next 14 days)',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            if (upcomingBills.isEmpty)
              Text(
                'No bills due in the next 14 days.',
                style: textTheme.bodyMedium,
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 240, // natural until 240px, then scroll
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: upcomingBills.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final bill = upcomingBills[index];
                    final isOverdue = billProvider.isOverdue(bill);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            bill.name,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isOverdue
                                  ? colorScheme.error
                                  : textTheme.bodyMedium?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatShortDate(bill.nextDueDate),
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatMoney(bill.amount),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isOverdue
                                ? colorScheme.error
                                : textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Basic list tile for a bill.
/// Tapping navigates to the bill detail screen.
class _BillListTile extends StatelessWidget {
  const _BillListTile({
    required this.bill,
  });

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final freqLabel = Bill.frequencyLabel(bill.frequency);

    final billProvider = context.read<BillProvider>();
    final isOverdue = billProvider.isOverdue(bill);
    final colorScheme = Theme.of(context).colorScheme;

    final titleStyle = isOverdue
        ? TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)
        : null;

    final amountStyle = isOverdue
        ? TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)
        : null;

    return Card(
      child: ListTile(
        title: Text(
          bill.name,
          style: titleStyle,
        ),
        subtitle: Text(
          '$freqLabel • Next due: ${formatShortDate(bill.nextDueDate)}',
        ),
        trailing: Text(
          formatMoney(bill.amount),
          style: amountStyle,
        ),
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

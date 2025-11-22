import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bill_provider.dart';
import '../models/bill.dart';
import '../utils/formatters.dart';
import 'add_edit_bill_screen.dart';
import 'bill_detail_screen.dart';
import 'settings_screen.dart';

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

    // Sort main list by next due date (soonest first)
    final sortedBills = [...bills]
      ..sort(
            (a, b) => a.nextDueDate.compareTo(b.nextDueDate),
      );

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
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

            // Heading for main list — use Baloo2 to match brand
            Text(
              'All Bills (${sortedBills.length})',
              style: textTheme.titleMedium?.copyWith(
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: sortedBills.isEmpty
                  ? _EmptyBillsState()
                  : ListView.builder(
                padding:
                const EdgeInsets.only(bottom: 80), // space for FAB
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
            // Heading uses Baloo2 as well
            Text(
              'Upcoming bills (next 14 days)',
              style: textTheme.titleMedium?.copyWith(
                fontFamily: 'Baloo2',
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

                    return _UpcomingBillRow(
                      bill: bill,
                      isOverdue: isOverdue,
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

class _UpcomingBillRow extends StatelessWidget {
  const _UpcomingBillRow({
    required this.bill,
    required this.isOverdue,
  });

  final Bill bill;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final dateText = formatShortDate(bill.nextDueDate);

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
          dateText,
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
  }
}

/// Empty state shown when there are no bills.
class _EmptyBillsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No bills yet',
            style: textTheme.titleMedium?.copyWith(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the + button to add your first bill.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
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
    final billProvider = context.read<BillProvider>();
    final isOverdue = billProvider.isOverdue(bill);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final freqLabel = Bill.frequencyLabel(bill.frequency);
    final dateText = formatShortDate(bill.nextDueDate);

    // Category-based icon
    final IconData iconData = _iconForBillName(bill.name);

    // Colors: category by shape, overdue by color
    final Color iconBgColor = isOverdue
        ? colorScheme.error.withOpacity(0.10)
        : colorScheme.primary.withOpacity(0.08);

    final Color iconColor = isOverdue
        ? colorScheme.error
        : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        // Leading status/category icon
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            size: 22,
            color: iconColor,
          ),
        ),

        // Title row: bill name + amount
        title: Row(
          children: [
            Expanded(
              child: Text(
                bill.name,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isOverdue ? colorScheme.error : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatMoney(bill.amount),
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color:
                isOverdue ? colorScheme.error : textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),

        // Subtitle row: frequency + due date
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$freqLabel • $dateText',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Trailing chevron for navigational cue
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
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

IconData _iconForBillName(String name) {
  final n = name.toLowerCase();

  // Car / transport
  if (n.contains('car') || n.contains('rego') || n.contains('fuel')) {
    return Icons.directions_car_filled;
  }

  // Health / medical insurance
  if (n.contains('health') ||
      n.contains('medic') ||
      n.contains('hospital') ||
      n.contains('hcf') ||
      n.contains('bupa') ||
      n.contains('nib') ||
      n.contains('cbhs')) {
    return Icons.health_and_safety;
  }

  // Phone / mobile
  if (n.contains('phone') ||
      n.contains('mobile') ||
      n.contains('sim') ||
      n.contains('telstra') ||
      n.contains('optus') ||
      n.contains('vodafone')) {
    return Icons.smartphone;
  }

  // Internet / wifi / NBN
  if (n.contains('internet') ||
      n.contains('wifi') ||
      n.contains('broadband') ||
      n.contains('nbn')) {
    return Icons.wifi;
  }

  // Music / streaming audio (Spotify, Apple Music, etc.)
  if (n.contains('spotify') ||
      n.contains('music') ||
      n.contains('apple music') ||
      n.contains('soundcloud')) {
    return Icons.music_note;
  }

  // Video streaming (Netflix, Prime, Disney, YouTube, etc.)
  if (n.contains('netflix') ||
      n.contains('prime') ||
      n.contains('disney') ||
      n.contains('youtube') ||
      n.contains('stan')) {
    return Icons.tv;
  }

  // Rent / mortgage / home
  if (n.contains('rent') ||
      n.contains('mortgage') ||
      n.contains('home loan') ||
      n.contains('house')) {
    return Icons.home_filled;
  }

  // Generic insurance
  if (n.contains('insurance') || n.contains('insurence')) {
    return Icons.shield_outlined;
  }

  // Power / electricity / gas
  if (n.contains('electricity') ||
      n.contains('power') ||
      n.contains('energy') ||
      n.contains('gas') ||
      n.contains('agl') ||
      n.contains('origin')) {
    return Icons.bolt;
  }

  // Generic subscription
  if (n.contains('subscription') || n.contains('sub ')) {
    return Icons.autorenew;
  }

  // Fallback
  return Icons.receipt_long;
}

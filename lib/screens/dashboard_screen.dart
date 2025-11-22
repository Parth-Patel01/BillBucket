import 'dart:async';
import 'package:bill_bucket/widgets/animated_press.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bill_provider.dart';
import '../models/bill.dart';
import '../utils/bill_icons.dart';
import '../utils/formatters.dart';
import 'add_edit_bill_screen.dart';
import 'bill_detail_screen.dart';
import 'settings_screen.dart';

/// Filters for the main bills list.
enum BillFilter { all, overdue, weekly, fortnightly, monthly, yearly }

/// Main dashboard screen.
///
/// Responsibilities:
/// - Shows high-level summary (monthly cost, recommended weekly transfer).
/// - Shows upcoming bills (next 14 days).
/// - Lists all bills with sorting and filtering.
/// - Provides FAB to add a new bill.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BillFilter _selectedFilter = BillFilter.all;

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final bills = billProvider.bills;
    final totalMonthly = billProvider.totalMonthlyCost;
    final weeklyTransfer = billProvider.recommendedWeeklyTransfer;
    final upcomingBills = billProvider.upcomingBills(daysAhead: 14);
    final textTheme = Theme.of(context).textTheme;

    // 1️⃣ Apply filter
    final filteredBills = bills.where((bill) {
      switch (_selectedFilter) {
        case BillFilter.all:
          return true;
        case BillFilter.overdue:
          return billProvider.isOverdue(bill);
        case BillFilter.weekly:
          return bill.frequency == BillFrequency.weekly;
        case BillFilter.fortnightly:
          return bill.frequency == BillFrequency.fortnightly;
        case BillFilter.monthly:
          return bill.frequency == BillFrequency.monthly;
        case BillFilter.yearly:
          return bill.frequency == BillFrequency.yearly;
      }
    }).toList();

    // 2️⃣ Sort filtered list by next due date (soonest first)
    final sortedBills = [...filteredBills]
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditBillScreen()));
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

                  // 🔹 Filter chips row
                  _FilterBar(
                    selected: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Heading for main list — use Baloo2 to match brand
                  Text(
                    'Bills (${sortedBills.length})',
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: sortedBills.isEmpty
                        ? _EmptyBillsState(
                            isFiltered: _selectedFilter != BillFilter.all,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 80,
                            ), // space for FAB
                            itemCount: sortedBills.length,
                            itemBuilder: (context, index) {
                              final bill = sortedBills[index];
                              return AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 300),
                                child: _BillListTile(bill: bill),
                              );
                            },
                          ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Horizontal filter bar using choice chips.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final BillFilter selected;
  final ValueChanged<BillFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = BillFilter.values;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_filterLabel(filter)),
              selected: isSelected,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              selectedColor: colorScheme.primary.withOpacity(0.15),
              onSelected: (value) {
                if (value) {
                  onSelected(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _filterLabel(BillFilter filter) {
    switch (filter) {
      case BillFilter.all:
        return 'All';
      case BillFilter.overdue:
        return 'Overdue';
      case BillFilter.weekly:
        return 'Weekly';
      case BillFilter.fortnightly:
        return 'Fortnightly';
      case BillFilter.monthly:
        return 'Monthly';
      case BillFilter.yearly:
        return 'Yearly';
    }
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
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          formatMoney(value),
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Card section for upcoming bills within the next 14 days.
/// Grows naturally but stops at a maximum height.
class _UpcomingBillsSection extends StatelessWidget {
  const _UpcomingBillsSection({required this.upcomingBills});

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

                    return _UpcomingBillRow(bill: bill, isOverdue: isOverdue);
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
  const _UpcomingBillRow({required this.bill, required this.isOverdue});

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
        Text(dateText, style: textTheme.bodySmall),
        const SizedBox(width: 8),
        Text(
          formatMoney(bill.amount),
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isOverdue ? colorScheme.error : textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

/// Empty state shown when there are no bills.
class _EmptyBillsState extends StatelessWidget {
  const _EmptyBillsState({this.isFiltered = false});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = isFiltered ? 'No bills match this filter' : 'No bills yet';
    final subtitle = isFiltered
        ? 'Try changing or clearing the filters above.'
        : 'Tap the + button to add your first bill.';

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
            title,
            style: textTheme.titleMedium?.copyWith(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BillListTile extends StatelessWidget {
  const _BillListTile({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final billProvider = context.read<BillProvider>();
    final isOverdue = billProvider.isOverdue(bill);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final freqLabel = Bill.frequencyLabel(bill.frequency);
    final dateText = formatShortDate(bill.nextDueDate);

    return Dismissible(
      key: ValueKey(bill.id),
      direction: DismissDirection.endToStart,

      // RED DELETE BACKGROUND
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: colorScheme.error,
          size: 28,
        ),
      ),

      // Confirm modal before deleting
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete bill'),
            content: Text(
              'Are you sure you want to delete "${bill.name}"?\n'
                  'This action can be undone briefly.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
            false;
      },

      // Handle actual delete + snackbar undo
      onDismissed: (direction) async {
        final deletedBill = bill; // keep backup

        await billProvider.deleteBill(bill.id);

        if (!context.mounted) return;

        final messenger = ScaffoldMessenger.of(context);

        messenger.clearSnackBars();

        final controller = messenger.showSnackBar(
          SnackBar(
            content: Text('Deleted "${deletedBill.name}".'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                billProvider.restoreBill(deletedBill);
              },
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 4), () async {
          // If snackbar is still visible, close it.
          messenger.hideCurrentSnackBar();
        });
      },

      child: AnimatedPress(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BillDetailScreen(billId: bill.id)),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0.5,
          shadowColor: Colors.black12,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),

            // Leading status icon (CATEGORY ICON)
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isOverdue
                    ? colorScheme.error.withOpacity(0.12)
                    : colorScheme.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconForBillName(bill.name),
                size: 22,
                color: isOverdue ? colorScheme.error : colorScheme.primary,
              ),
            ),

            // Main title row: name + amount
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    bill.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? colorScheme.error : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatMoney(bill.amount),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isOverdue ? colorScheme.error : null,
                  ),
                ),
              ],
            ),

            // Subtitle row: frequency and due date
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "$freqLabel • $dateText",
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing chevron indicator
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import 'add_edit_bill_screen.dart';

import '../utils/formatters.dart';


/// Shows full information about a single bill and actions:
/// - Mark as paid today (updates next due date)
/// - Edit bill
/// - Delete bill
class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({super.key, required this.billId});

  /// We pass only the ID so this screen always reads
  /// the latest data from the provider.
  final String billId;

  @override
  Widget build(BuildContext context) {
    // Listen to changes to this specific bill.
    final bill = context.select<BillProvider, Bill?>(
      (provider) => provider.getBillById(billId),
    );

    if (bill == null) {
      // This can happen if bill was deleted from elsewhere.
      return Scaffold(
        appBar: AppBar(title: const Text('Bill details')),
        body: const Center(child: Text('This bill no longer exists.')),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<BillProvider>();
    final paidToday = provider.isPaidToday(bill.lastPaidDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(bill.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete bill',
            onPressed: () => _confirmDelete(context, bill),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Amount
              _DetailRow(
                label: 'Amount',
                value: formatMoney(bill.amount),
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              // Frequency
              _DetailRow(
                label: 'Frequency',
                value: Bill.frequencyLabel(bill.frequency),
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              // Next due date
              _DetailRow(
                label: 'Next due date',
                value: _formatDate(bill.nextDueDate),
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),

              // Last paid date
              _DetailRow(
                label: 'Last paid',
                value: bill.lastPaidDate != null
                    ? _formatDate(bill.lastPaidDate!)
                    : 'Not paid yet',
                textTheme: textTheme,
              ),
              const SizedBox(height: 24),

              // Actions: Mark as paid and Edit
              SizedBox(
                width: double.infinity,
                child: paidToday
                    ? ElevatedButton.icon(
                        icon: const Icon(Icons.undo),
                        label: const Text('Undo – mark as unpaid'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () async {
                          await provider.undoPayment(bill.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment undone.')),
                            );
                          }
                        },
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as paid today'),
                        onPressed: () => _onMarkAsPaid(context, bill),
                      ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit bill'),
                  onPressed: () => _onEdit(context, bill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles "Mark as paid today" action.
  Future<void> _onMarkAsPaid(BuildContext context, Bill bill) async {
    final provider = context.read<BillProvider>();
    final now = DateTime.now();

    await provider.markBillAsPaid(id: bill.id, paidDate: now);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Marked ${bill.name} as paid. Next due: '
            '${_formatDate(provider.getBillById(bill.id)!.nextDueDate)}',
          ),
        ),
      );
    }
  }

  /// Opens the AddEditBillScreen in edit mode.
  void _onEdit(BuildContext context, Bill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditBillScreen(existingBill: bill)),
    );
  }

  /// Shows a confirmation dialog before deleting the bill.
  Future<void> _confirmDelete(BuildContext context, Bill bill) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete bill'),
            content: Text(
              'Are you sure you want to delete "${bill.name}"?\n'
              'This action cannot be undone.',
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

    if (!shouldDelete) return;

    final provider = context.read<BillProvider>();
    await provider.deleteBill(bill.id);

    if (context.mounted) {
      Navigator.of(context).pop(); // Go back after deleting
    }
  }
}

/// Small reusable row widget for displaying label/value pairs.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Text(value, style: textTheme.bodyMedium)),
      ],
    );
  }
}

/// Simple date formatting helper (DD/MM/YYYY).
String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

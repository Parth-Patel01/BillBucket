import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';

/// Screen used for both creating a new bill and editing an existing one.
///
/// If [existingBill] is null → "Add Bill" mode.
/// If [existingBill] is provided → "Edit Bill" mode.
class AddEditBillScreen extends StatefulWidget {
  const AddEditBillScreen({
    super.key,
    this.existingBill,
  });

  final Bill? existingBill;

  @override
  State<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends State<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;

  BillFrequency _selectedFrequency = BillFrequency.monthly;
  DateTime? _selectedNextDueDate;

  bool get _isEditMode => widget.existingBill != null;

  @override
  void initState() {
    super.initState();

    // If editing, prefill the form with existing values; otherwise defaults.
    final existing = widget.existingBill;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _selectedFrequency = existing?.frequency ?? BillFrequency.monthly;
    _selectedNextDueDate = existing?.nextDueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Opens the date picker for selecting the next due date.
  Future<void> _pickNextDueDate() async {
    final initialDate = _selectedNextDueDate ?? DateTime.now();
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedNextDueDate = picked;
      });
    }
  }

  /// Validates form and either creates a new bill or updates an existing one.
  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) {
      return; // Invalid input → do not proceed.
    }

    if (_selectedNextDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a next due date.')),
      );
      return;
    }

    final billProvider = context.read<BillProvider>();

    final name = _nameController.text.trim();
    final parsedAmount = double.tryParse(_amountController.text.trim());

    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    if (_isEditMode) {
      final existing = widget.existingBill!;
      // Use provider helper to update specific fields.
      await billProvider.updateBillFields(
        existing.id,
        name: name,
        amount: parsedAmount,
        frequency: _selectedFrequency,
        nextDueDate: _selectedNextDueDate!,
      );
    } else {
      // Create a new bill.
      await billProvider.addBill(
        name: name,
        amount: parsedAmount,
        frequency: _selectedFrequency,
        nextDueDate: _selectedNextDueDate!,
      );
    }

    if (mounted) {
      Navigator.of(context).pop(); // Go back after saving.
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Bill' : 'Add Bill';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Bill name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bill name',
                    hintText: 'e.g. Car Insurance',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a bill name.';
                    }
                    if (value.trim().length < 3) {
                      return 'Name should be at least 3 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'e.g. 120.50',
                    prefixText: '\$',
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount.';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Frequency dropdown
                DropdownButtonFormField<BillFrequency>(
                  value: _selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                  ),
                  items: BillFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(Bill.frequencyLabel(freq)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue == null) return;
                    setState(() {
                      _selectedFrequency = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Next due date picker
                InkWell(
                  onTap: _pickNextDueDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Next due date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedNextDueDate == null
                              ? 'Select date'
                              : '${_selectedNextDueDate!.day.toString().padLeft(2, '0')}/'
                              '${_selectedNextDueDate!.month.toString().padLeft(2, '0')}/'
                              '${_selectedNextDueDate!.year}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(_isEditMode ? 'Save changes' : 'Add bill'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

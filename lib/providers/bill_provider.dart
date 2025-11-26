import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/bill.dart';
import '../utils/formatters.dart';

/// Central place for managing bills state and business logic.
///
/// Responsibilities:
/// - Load bills from Hive on app start.
/// - Provide read-only access to the bills list for the UI.
/// - Add, update, and delete bills in memory + Hive.
/// - Provide computed values for dashboard (monthly cost, weekly transfer, etc.).
class BillProvider extends ChangeNotifier {
  BillProvider({
    required Box<Bill> billsBox,
  }) : _billsBox = billsBox {
    _loadBills();
  }

  /// Hive box instance that actually stores Bill objects on disk.
  final Box<Bill> _billsBox;

  /// Internal mutable list. Never expose this directly.
  final List<Bill> _bills = [];

  /// UUID generator for new bills.
  static const _uuid = Uuid();

  /// Public, read-only view of bills for widgets to consume.
  ///
  /// This prevents external code from modifying the list without going
  /// through the provider’s methods (which also persist to Hive).
  UnmodifiableListView<Bill> get bills => UnmodifiableListView(_bills);

  /// Returns true when initial data has been loaded from Hive.
  ///
  /// Useful if you want to show a loading indicator while bills are loading.
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Loads existing bills from Hive into memory.
  ///
  /// Called once in the constructor. You typically don’t need to call this
  /// manually.
  void _loadBills() {
    _bills
      ..clear()
      ..addAll(_billsBox.values);
    _isInitialized = true;
    notifyListeners();
  }

  /// Returns a single bill by its id, or null if not found.
  Bill? getBillById(String id) {
    try {
      return _bills.firstWhere((bill) => bill.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Adds a new bill.
  ///
  /// Prefer this method instead of creating and inserting Bill objects
  /// manually – this ensures:
  /// - A unique id is generated.
  /// - Data is saved to Hive.
  /// - Listeners are notified.
  Future<Bill> addBill({
    required String name,
    required double amount,
    required BillFrequency frequency,
    required DateTime nextDueDate,
  }) async {
    final newBill = Bill(
      id: _uuid.v4(),
      name: name.trim(),
      amount: amount,
      frequency: frequency,
      nextDueDate: stripTime(nextDueDate),
      lastPaidDate: null,
    );

    // Persist to Hive first to keep source of truth consistent.
    await _billsBox.put(newBill.id, newBill);

    // Then update in-memory list.
    _bills.add(newBill);
    notifyListeners();

    return newBill;
  }

  /// Updates an existing bill.
  ///
  /// `updated` should be a full Bill object (usually created via copyWith).
  Future<void> updateBill(Bill updated) async {
    final index = _bills.indexWhere((bill) => bill.id == updated.id);
    if (index == -1) return;

    await _billsBox.put(updated.id, updated);
    _bills[index] = updated;
    notifyListeners();
  }

  /// Convenience helper to update specific fields of a bill by id.
  ///
  /// This avoids duplicating `copyWith` logic in the UI layer.
  Future<void> updateBillFields(
      String id, {
        String? name,
        double? amount,
        BillFrequency? frequency,
        DateTime? nextDueDate,
        DateTime? lastPaidDate,
      }) async {
    final bill = getBillById(id);
    if (bill == null) return;

    final updated = bill.copyWith(
      name: name?.trim(),
      amount: amount,
      frequency: frequency,
      nextDueDate: nextDueDate != null ? stripTime(nextDueDate) : null,
      lastPaidDate: lastPaidDate != null ? stripTime(lastPaidDate) : null,
    );

    await updateBill(updated);
  }

  /// Deletes a bill from Hive and in-memory list.
  Future<void> deleteBill(String id) async {
    await _billsBox.delete(id);
    _bills.removeWhere((bill) => bill.id == id);
    notifyListeners();
  }

  /// Marks a bill as paid on a given date (usually today).
  ///
  /// This will:
  /// - Update lastPaidDate.
  /// - Calculate the next due date based on frequency.
  Future<void> markBillAsPaid({
    required String id,
    required DateTime paidDate,
  }) async {
    final bill = getBillById(id);
    if (bill == null) return;

    final normalizedPaidDate = stripTime(paidDate);
    final nextDueDate = _calculateNextDueDate(
      from: normalizedPaidDate,
      frequency: bill.frequency,
    );

    final updated = bill.copyWith(
      lastPaidDate: normalizedPaidDate,
      nextDueDate: nextDueDate,
    );

    await updateBill(updated);
  }

  /// Calculates an approximate monthly equivalent cost for all bills.
  ///
  /// This is useful for showing:
  /// - "Total monthly cost" on the dashboard.
  double get totalMonthlyCost {
    double total = 0.0;

    for (final bill in _bills) {
      switch (bill.frequency) {
        case BillFrequency.weekly:
          total += bill.amount * 52 / 12; // 52 weeks/year → monthly
          break;
        case BillFrequency.fortnightly:
          total += bill.amount * 26 / 12; // 26 fortnights/year
          break;
        case BillFrequency.monthly:
          total += bill.amount; // already monthly
          break;
        case BillFrequency.yearly:
          total += bill.amount / 12; // yearly → monthly
          break;
      }
    }

    return total;
  }

  /// Recommended weekly transfer so that all bills are covered.
  ///
  /// Simple formula:
  /// - Convert everything to yearly amount, then divide by 52.
  double get recommendedWeeklyTransfer {
    double yearlyTotal = 0.0;

    for (final bill in _bills) {
      switch (bill.frequency) {
        case BillFrequency.weekly:
          yearlyTotal += bill.amount * 52;
          break;
        case BillFrequency.fortnightly:
          yearlyTotal += bill.amount * 26;
          break;
        case BillFrequency.monthly:
          yearlyTotal += bill.amount * 12;
          break;
        case BillFrequency.yearly:
          yearlyTotal += bill.amount;
          break;
      }
    }

    if (yearlyTotal == 0) return 0.0;
    return yearlyTotal / 52.0;
  }

  /// Upcoming bills within the given number of days from [fromDate].
  ///
  /// Default is 14 days. Result is sorted by date ascending.
  List<Bill> upcomingBills({
    int daysAhead = 14,
    DateTime? fromDate,
  }) {
    final now = stripTime(fromDate ?? DateTime.now());
    final end = now.add(Duration(days: daysAhead));

    final result = _bills
        .where(
          (bill) =>
      bill.nextDueDate
          .isAfter(now.subtract(const Duration(days: 1))) &&
          bill.nextDueDate
              .isBefore(end.add(const Duration(days: 1))),
    )
        .toList();

    result.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return result;
  }

  /// Internal helper for frequency-based next due date calculation.
  DateTime _calculateNextDueDate({
    required DateTime from,
    required BillFrequency frequency,
  }) {
    switch (frequency) {
      case BillFrequency.weekly:
        return from.add(const Duration(days: 7));
      case BillFrequency.fortnightly:
        return from.add(const Duration(days: 14));
      case BillFrequency.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case BillFrequency.yearly:
        return DateTime(from.year + 1, from.month, from.day);
    }
  }

  bool isPaidToday(DateTime? paidDate) {
    if (paidDate == null) return false;
    final now = DateTime.now();
    return paidDate.year == now.year &&
        paidDate.month == now.month &&
        paidDate.day == now.day;
  }

  Future<void> undoPayment(String id) async {
    final bill = getBillById(id);
    if (bill == null) return;

    // Undo only resets lastPaidDate; do NOT touch nextDueDate.
    final updated = bill.copyWith(
      clearLastPaidDate: true, // assumes Bill.copyWith supports this flag
    );

    await updateBill(updated);
  }

  /// Returns true if the bill is overdue (nextDueDate is before today).
  bool isOverdue(Bill bill) {
    final today = stripTime(DateTime.now());
    final dueDate = stripTime(bill.nextDueDate);
    return dueDate.isBefore(today);
  }

  /// Restores a previously deleted bill.
  ///
  /// Used for "Undo" after swipe-to-delete.
  Future<void> restoreBill(Bill bill) async {
    // Avoid duplicates if somehow called twice.
    if (getBillById(bill.id) != null) return;

    await _billsBox.put(bill.id, bill);
    _bills.add(bill);
    notifyListeners();
  }
}

import 'package:hive/hive.dart';

part 'bill.g.dart';

/// Frequency of a recurring bill.
/// Using enums avoids invalid strings and makes date-math easier.
@HiveType(typeId: 1)
enum BillFrequency {
  @HiveField(0)
  weekly,

  @HiveField(1)
  fortnightly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  yearly,
}

/// Core data model representing a bill.
///
/// This class is:
/// - Immutable (all fields final) which avoids bugs.
/// - Serializable through Hive using type adapters.
/// - Structured for easy state management and UI display.
@HiveType(typeId: 2)
class Bill extends HiveObject {
  // Unique ID for referencing/updating this bill inside Hive.
  @HiveField(0)
  final String id;

  // Display name of the bill (e.g., “Car Insurance”)
  @HiveField(1)
  final String name;

  // Amount due every cycle.
  @HiveField(2)
  final double amount;

  // Recurrence cycle (weekly, monthly, etc.).
  @HiveField(3)
  final BillFrequency frequency;

  // The next date when the bill is due.
  @HiveField(4)
  final DateTime nextDueDate;

  // When the bill was last paid.
  @HiveField(5)
  final DateTime? lastPaidDate;

  Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    this.lastPaidDate,
  });

  /// Creates a new updated copy of this Bill (immutable pattern).
  ///
  /// Note: [clearLastPaidDate] allows explicitly setting lastPaidDate to null,
  /// because nullable fields can't be cleared with simple `??` logic.
  Bill copyWith({
    String? id,
    String? name,
    double? amount,
    BillFrequency? frequency,
    DateTime? nextDueDate,
    DateTime? lastPaidDate,
    bool clearLastPaidDate = false,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastPaidDate: clearLastPaidDate
          ? null
          : (lastPaidDate ?? this.lastPaidDate),
    );
  }


  /// Converts a BillFrequency enum into a readable string for UI.
  static String frequencyLabel(BillFrequency freq) {
    switch (freq) {
      case BillFrequency.weekly:
        return 'Weekly';
      case BillFrequency.fortnightly:
        return 'Fortnightly';
      case BillFrequency.monthly:
        return 'Monthly';
      case BillFrequency.yearly:
        return 'Yearly';
    }
  }

  /// Converts the model to a debug-friendly string (optional).
  @override
  String toString() {
    return 'Bill(id: $id, name: $name, amount: $amount, '
        'frequency: $frequency, nextDueDate: $nextDueDate, lastPaidDate: $lastPaidDate)';
  }
}

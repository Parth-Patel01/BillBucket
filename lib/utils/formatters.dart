import 'package:intl/intl.dart';

/// ---------------------------------------------------------
/// CURRENCY FORMATTER
/// ---------------------------------------------------------

final NumberFormat _currencyFormatter = NumberFormat.currency(
  locale: 'en_AU',
  symbol: '\$',
  decimalDigits: 2,
);

String formatMoney(double value) {
  return _currencyFormatter.format(value);
}

/// ---------------------------------------------------------
/// DATE FORMATTERS
/// ---------------------------------------------------------

/// Formats as DD/MM/YYYY (e.g., 05/11/2025)
String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

/// Formats as: Tue, 05 Nov 2025
final DateFormat _longDateFormatter = DateFormat('EEE, dd MMM yyyy');

String formatLongDate(DateTime date) {
  return _longDateFormatter.format(date);
}

/// Normalized date (strip time)
DateTime stripTime(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

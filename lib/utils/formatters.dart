import 'package:intl/intl.dart';

/// Global currency formatter.
///
/// Uses Australian locale and `$` symbol, but you can tweak if needed.
final NumberFormat _currencyFormatter = NumberFormat.currency(
  locale: 'en_AU',
  symbol: '\$',
  decimalDigits: 2,
);

/// Formats a double as money string, e.g. 1234.5 → $1,234.50
String formatMoney(double value) {
  return _currencyFormatter.format(value);
}

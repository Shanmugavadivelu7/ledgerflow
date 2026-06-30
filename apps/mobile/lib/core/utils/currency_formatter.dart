import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

  static String format(num amount) => _fmt.format(amount);
}

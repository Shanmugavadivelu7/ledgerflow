import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _date = DateFormat('d MMM yyyy');
  static final _dateTime = DateFormat('d MMM yyyy, h:mm a');
  static final _api = DateFormat('yyyy-MM-dd');

  static String date(DateTime d) => _date.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);
  static String forApi(DateTime d) => _api.format(d);
}

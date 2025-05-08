import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String toFormattedString() {
    String dayStr = day.toString().padLeft(2, '0'); // Ensure two digits
    String monthStr = month.toString().padLeft(2, '0'); // Ensure two digits
    return '$dayStr/$monthStr/$year';
  }
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }
  DateTime addHours(int hours) {
    return add(Duration(hours: hours));
  }
  DateTime addMinutes(int minutes) {
    return add(Duration(minutes: minutes));
  }
  // Same format with saved date in database
  DateTime standardFormatDate() {
    return DateFormat('yyyy-MM-dd').parse(toString());
  }
  // Same format with saved datetime in database
  DateTime standardFormatDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(toString());
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateExt on DateTime {
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
  String standardFormatString() {
    String yearStr = year.toString();
    String monthStr = month.toString();
    String dayStr = day.toString();
    return "$yearStr-$monthStr-$dayStr";
  }
  // Same format with saved datetime in database
  DateTime standardFormatDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(toString());
  }
}

extension TimeExt on String {
  String HH_mm() {
    final str = toString();
    final parts = str.split(':');
    return '${parts[0]}:${parts[1]}';
  }
}
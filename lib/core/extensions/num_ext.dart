import 'package:intl/intl.dart';

extension NumExt on num {
  String formatNumber() {
    return NumberFormat("#,###", "vi_VN").format(this);
  }

  String formatDuration() {
    final hours = this ~/ 60;
    final minutes = this % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours tiếng $minutes phút';
    } else if (hours > 0) {
      return '$hours tiếng';
    } else {
      return '$minutes phút';
    }
  }
}


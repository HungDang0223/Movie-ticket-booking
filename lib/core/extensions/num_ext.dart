import 'package:intl/intl.dart';

extension NumExt on num {
  String formatNumber() {
    return NumberFormat("#,###", "vi_VN").format(this);
  }
}


import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:movie_tickets/core/configs/zalopay_config.dart';

String getBankCode() => "zalopayapp";
String getDescription(String apptransid) => "Merchant Demo thanh toán cho đơn hàng  #$apptransid";

String getMacCreateOrder(String data) {
  var hmac =  Hmac(sha256, utf8.encode(ZaloPayConfig.key1));
  return hmac.convert(utf8.encode(data)).toString();
}

int transIdDefault = 1;
String getAppTransId() {
  if (transIdDefault >= 100000) {
    transIdDefault = 1;
  }

  transIdDefault += 1;
  var timeString = DateFormat("yyMMdd_hhmmss").format(DateTime.now());
  return "$timeString$transIdDefault";
}


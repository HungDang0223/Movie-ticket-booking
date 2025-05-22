
import 'package:dio/dio.dart';
import 'package:movie_tickets/core/configs/zalopay_config.dart';
import 'package:movie_tickets/core/utils/zalopay_utils.dart';
import 'package:movie_tickets/core/configs/payment_config.dart';
import 'package:movie_tickets/features/payment/data/models/zalopay_order_response.dart';

class ZalopayPaymentService {
  final _dio = Dio();
  ZalopayPaymentService._();

  static final ZalopayPaymentService _instance = ZalopayPaymentService._();

  static ZalopayPaymentService get instance => _instance;
  
  Future<ZalopayOrderResponse?> createOrder(int amount) async {
    var header = <String, String>{};
    header["Content-Type"] = "application/x-www-form-urlencoded";

    var body = <String, String>{};
    body["app_id"] = ZaloPayConfig.appId;
    body["app_user"] = ZaloPayConfig.appUser;
    body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
    body["amount"] = amount.toStringAsFixed(0);
    body["app_trans_id"] = getAppTransId();
    body["embed_data"] = "{}";
    body["item"] = "[]";
    body["bank_code"] = getBankCode();
    body["description"] = getDescription(body["app_trans_id"]!);

    var dataGetMac =
        "${body["app_id"]}|${body["app_trans_id"]}|${body["app_user"]}|${body["amount"]}|${body["app_time"]}|${body["embed_data"]}|${body["item"]}";

    body["mac"] = getMacCreateOrder(dataGetMac);
    print("mac: ${body["mac"]}");
    
    final response = await _dio.post(
      PaymentConfig.createOrderUrl,
      data: FormData.fromMap(body),
      options: Options(headers: header),
    );

    print("body_request: $body");
    if (response.statusCode != 200) {
      return null;
    }

    var data = response.data;
    print("data_response: $data}");

    return ZalopayOrderResponse.fromJson(data);
  }
}
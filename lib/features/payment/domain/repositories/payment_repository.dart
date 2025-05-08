import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/payment/data/models/zalopay_order_response.dart';

abstract class PaymentRepository {
  Future<Result<PaymentIntent>> processStripePayment(double amount, {String currency = 'vnd'});
  Future<Result<ZalopayOrderResponse>> processZaloPayPayment(double amount);
  Future<Result<String>> processMomoPayment();
  Future<Result<String>> processVNPAYPayment();
}
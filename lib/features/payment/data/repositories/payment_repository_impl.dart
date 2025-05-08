import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_tickets/core/configs/payment_config.dart';
import 'package:movie_tickets/core/configs/zalopay_config.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/core/utils/zalopay_utils.dart';
import 'package:movie_tickets/features/payment/data/models/payment_card.dart';
import 'package:movie_tickets/features/payment/data/models/zalopay_order_response.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';
import 'package:stripe_platform_interface/src/models/payment_intents.dart';

class PaymentRepositoryImpl implements PaymentRepository{
  final Dio _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.stripe.com/v1',
        headers: {
          'Authorization': 'Bearer ${PaymentConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    
  @override
  Future<Result<PaymentIntent>> processStripePayment(double amount, {String currency = 'vnd'}) async {
      try {
        // Step 1: Create a payment intent
        final clientSecret = await createPaymentIntent(amount, currency);
        // Step 2: Initialize the payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: PaymentConfig.merchantName,
            customFlow: true,
            allowsDelayedPaymentMethods: false,
            intentConfiguration: IntentConfiguration(
              paymentMethodTypes: [
                'card',
              ],
              mode: IntentMode.paymentMode(currencyCode: currency, amount: amount.round(), setupFutureUsage: IntentFutureUsage.OffSession),
            ),
            appearance: const PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: AppColor.BLACK,
                background: AppColor.WHITE,
                componentBackground: AppColor.WHITE,
              ),
            ),
          ),
        );
        
        // Step 3: Present the payment sheet to the user
        await Stripe.instance.presentPaymentSheet(
          options: const PaymentSheetPresentOptions(
            // timeout: 30000,
          )
        );

        await Stripe.instance.confirmPaymentSheetPayment();

        final intent = await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret!,
        );

        print(intent.status.name);
        return Result.success(intent);
      } catch (e) {
        print('Error presenting payment sheet: $e');
        
        if (e is StripeException) {
          print('StripeException: ${e.error.message}');
          }
        }
        return Result.fromFailure(ServerFailure('Error presenting payment sheet: $e'));
    }

    // Create Payment Intent
  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      final response = await _dio.post(
        '/payment_intents',
        data: {
          'amount': amount.round().toString(), // Convert to smallest currency unit
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      return response.data['client_secret'];
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }

  // Process payment with card details
    Future<Map<String, dynamic>> processPayment(
      PaymentCard card, 
      double amount, 
      {String currency = 'vnd'}
    ) async {
      try {
        
        // Step 1: Create a payment intent
        final clientSecret = await createPaymentIntent(amount, currency);
        print('Client secret: $clientSecret');
        // Step 2: Confirm payment with the card details
        // In a real app, you'd use the card collected by the payment sheet
        final billingDetails = BillingDetails(
          name: card.cardHolderName,
        );
        
        // This is only for demo - in a real app, you'd use a more secure approach
        // such as Stripe's PaymentSheet or PaymentIntents API with the collected card token
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ),
        );
        print('Payment method: $paymentMethod');
        
        // Confirm the payment with the created payment method
        final result = await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret!,
          data: PaymentMethodParams.cardFromMethodId(
            paymentMethodData: PaymentMethodDataCardFromMethod(
              paymentMethodId: paymentMethod.id,
              billingDetails: billingDetails,
            ),
          ),
        );
        
        return {
          'status': 'succeeded',
          'id': result.id,
        };
      } catch (e) {
        print('Error processing payment: $e');
        return {
          'status': 'failed',
        };
      }
    }

  @override
  Future<Result<String>> processMomoPayment() {
    // TODO: implement processMomoPayment
    throw UnimplementedError();
  }

  @override
  Future<Result<String>> processVNPAYPayment() {
    // TODO: implement processVNPAYPayment
    throw UnimplementedError();
  }

  @override
  Future<Result<ZalopayOrderResponse>> processZaloPayPayment(double amount) {
    // TODO: implement processZaloPayPayment
    throw UnimplementedError();
  }

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
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment_card.dart';
import '../../../../core/configs/payment_config.dart';

class StripePaymentService {

  StripePaymentService._();

  static final StripePaymentService _instance = StripePaymentService._();

  static StripePaymentService get instance => _instance;

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

// Create Payment Intent
Future<String?> createPaymentIntent(double amount, String currency) async {
  _dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ),
  );

  final data = {
    'amount': amount.round().toString(),  // Stripe expects amount in cents
    'currency': currency,
    'payment_method_types[]': 'card',  // Encode array as indexed keys
  };

  try {
    final response = await _dio.post('/payment_intents', data: data);

    return response.data['client_secret'];
  } catch (e) {
    print('Error creating payment intent: $e');
    return null;
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
  
  // Process payment using the PaymentSheet (recommended way)
  Future processPaymentWithSheet(double amount, {String currency = 'vnd'}) async {
    try {
      
      // Step 1: Create a payment intent
      final clientSecret = await createPaymentIntent(amount, currency);
      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: PaymentConfig.merchantName,
          intentConfiguration: IntentConfiguration(
            paymentMethodTypes: [
              'card',
            ],
            mode: IntentMode.paymentMode(currencyCode: currency, amount: amount.round()),
          ),
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.black,
              background: Colors.white,
              componentBackground: Colors.white,
            ),
          ),
        ),
      );
      
      // Step 3: Present the payment sheet to the user
      await Stripe.instance.presentPaymentSheet(
        options: PaymentSheetPresentOptions(
          // timeout: 30000,

        )
      );

      final a = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret!,
      );

      print(a.status.name);
    } catch (e) {
      print('Error presenting payment sheet: $e');
      
      if (e is StripeException) {
        print('StripeException: ${e.error.message}');
        }
      }
    }
  }
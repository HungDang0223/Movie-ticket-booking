import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../data/models/payment_card.dart';
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
  
  // Process payment using the PaymentSheet (recommended way)
  Future<PaymentIntent?> processPaymentWithSheet(double amount, {String currency = 'vnd'}) async {
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
              primary: Colors.black,
              background: Colors.white,
              componentBackground: Colors.white,
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
      return intent;
    } catch (e) {
      print('Error presenting payment sheet: $e');
      
      if (e is StripeException) {
        print('StripeException: ${e.error.message}');
        }
      }
      return null;
    }
  }
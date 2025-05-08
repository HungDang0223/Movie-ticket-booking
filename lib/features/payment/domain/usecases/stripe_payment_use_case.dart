import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/payment/data/models/payment_card.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';

class StripePaymentUseCase implements UseCase<PaymentIntent, StripePaymentParams> {
  final PaymentRepository _repository;

  StripePaymentUseCase(this._repository);

  @override
  Future<Result<PaymentIntent>> call(StripePaymentParams params) async {
    try {
      final a = await _repository.processStripePayment(params.amout);
      return a;
    } catch (e) {
      log("Stripe payment error occured: $e", name: "Payment");
      return Result.fromFailure(ServerFailure(e.toString()));
    }
  }
}

class StripePaymentParams {
  final double amout;

  StripePaymentParams({required this.amout});
}
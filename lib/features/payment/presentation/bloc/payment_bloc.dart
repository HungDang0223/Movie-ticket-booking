import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';
import 'package:movie_tickets/features/payment/domain/services/zalopay_payment_service.dart';
import 'package:movie_tickets/features/payment/domain/usecases/stripe_payment_use_case.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_event.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc  extends Bloc<PaymentEvent, PaymentState>{
  final PaymentRepository paymentRepository;
  static const MethodChannel platform = MethodChannel('flutter.native/channelPayOrder');
  
  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<ProcessStripePayment>(_onProcessStripePayment);
    on<ProcessZaloPayPayment>(_onProcessZaloPayPayment);
    on<ProcessMomoPayment>(_onProcessMomoPayment);
    on<ProcessVNPAYPayment>(_onProcessVNPAYPayment);
  }

  Stream<PaymentState> _onProcessStripePayment(ProcessStripePayment event, Emitter<PaymentState> emit) async* {
    yield PaymentProcessing();
    try {
      final stripePaymentUseCase = StripePaymentUseCase(paymentRepository);
      final params = StripePaymentParams(amout: event.amount);
      // Process payment using the StripePaymentService
      final result = await stripePaymentUseCase.call(params);

      if (result.isSuccess && result.data != null) {
        yield PaymentSuccess(result.data!.id);
      } else {
        yield PaymentFailure('Payment failed ${result.failure!.message}');
      }
    } catch (e) {
      yield PaymentFailure("Payment error occured: ${e.toString()}");
    }
  }

  Future<void> _onProcessZaloPayPayment(ProcessZaloPayPayment event, Emitter<PaymentState> emit) async {
    emit(PaymentProcessing());
    try {
          // Step 1: Create the order
          final order = await ZalopayPaymentService.instance.createOrder(event.amount.round());

          if (order != null) {
            final zpTransToken = order.zptranstoken;
            if (order.returncode == 1) {

              emit(PaymentSuccess(zpTransToken));
              // Navigate to success screen or show dialog
              print("✅ Payment success");
            } else if (order.returncode == 4) {
              emit(PaymentFailure("Payment canceled by user"));
              print("⚠️ User canceled the payment");
            } else {
              emit(PaymentFailure("Payment failed with code: ${order.returncode}"));
              print("❌ Payment failed");
            }

            // Step 2: Start payment via native Android (invoke MethodChannel)
            final result = await platform.invokeMethod('payOrder', {
              "zptoken": zpTransToken,
            });

            // Step 3: Handle result
            print("payOrder Result: '$result'.");
            
            
          } else {
            print("❌ Failed to create order or missing token.");
          }
        } catch (e) {
          print("Exception during ZaloPay flow: $e");
        }
  }

  Stream<PaymentState> _onProcessMomoPayment(ProcessMomoPayment event, Emitter<PaymentState> emit) async* {
    yield PaymentProcessing();
    try {
      
    } catch (e) {
      
    }
  }

  Stream<PaymentState> _onProcessVNPAYPayment(ProcessVNPAYPayment event, Emitter<PaymentState> emit) async* {
    yield PaymentProcessing();
    try {
      
    } catch (e) {
      
    }
  }

}
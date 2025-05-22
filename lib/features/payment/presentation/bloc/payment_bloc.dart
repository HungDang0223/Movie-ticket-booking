import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';
import 'package:movie_tickets/features/payment/domain/usecases/stripe_payment_use_case.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_event.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc  extends Bloc<PaymentEvent, PaymentState>{
  final PaymentRepository paymentRepository;
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

  Stream<PaymentState> _onProcessZaloPayPayment(ProcessZaloPayPayment event, Emitter<PaymentState> emit) async* {
    yield PaymentProcessing();
    try {
      
    } catch (e) {
      yield PaymentFailure("Payment error occured: ${e.toString()}");
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
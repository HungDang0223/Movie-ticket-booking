import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentProcessing extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String transactionId;

  PaymentSuccess(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class PaymentFailure extends PaymentState {
  final String error;

  PaymentFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class PaymentCanceled extends PaymentState {
  
}

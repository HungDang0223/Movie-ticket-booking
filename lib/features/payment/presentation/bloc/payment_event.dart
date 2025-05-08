import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/payment/data/models/payment_card.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProcessStripePayment extends PaymentEvent {
  final PaymentCard card;
  final double amount;

  ProcessStripePayment(this.card, this.amount);

  @override
  List<Object?> get props => [card, amount];
}

class ProcessZaloPayPayment extends PaymentEvent {
  final double amount;

  ProcessZaloPayPayment(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ProcessMomoPayment extends PaymentEvent {}

class ProcessVNPAYPayment extends PaymentEvent {}

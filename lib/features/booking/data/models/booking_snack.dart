import 'package:movie_tickets/features/booking/data/models/snack.dart';

class BookingSnack {
  final int bookingId;
  final Snack snack;
  final int quantity;
  double get totalPrice => snack.price * quantity;

  BookingSnack({
    required this.bookingId,
    required this.snack,
    required this.quantity,
  });
  factory BookingSnack.fromJson(Map<String, dynamic> json) {
    return BookingSnack(
      bookingId: json['bookingId'] as int,
      snack: Snack.fromJson(json['snack'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'snack': snack.toJson(),
      'quantity': quantity,
    };
  }
}
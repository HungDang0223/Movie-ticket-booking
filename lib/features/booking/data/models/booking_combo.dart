import 'package:movie_tickets/features/booking/data/models/combo.dart';

class BookingCombo {
  final int bookingId;
  final Combo combo;
  final int quantity;
  int get totalPrice => combo.price * quantity;

  const BookingCombo({
    required this.bookingId,
    required this.combo,
    required this.quantity,
  });
  factory BookingCombo.fromJson(Map<String, dynamic> json) {
    return BookingCombo(
      bookingId: json['bookingId'] as int,
      combo: Combo.fromJson(json['combo'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'combo': combo.toJson(),
      'quantity': quantity,
    };
  }
}
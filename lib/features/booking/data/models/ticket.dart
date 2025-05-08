import 'package:movie_tickets/features/booking/data/models/booking_combo.dart';
import 'package:movie_tickets/features/booking/data/models/booking_seat.dart';
import 'package:movie_tickets/features/booking/data/models/booking_snack.dart';
import 'package:movie_tickets/features/booking/data/models/showing.dart';

class Ticket {
  final int bookingId;
  final String userId;
  final Showing showing;
  final DateTime bookTime;
  final int amount;
  final BookingSeat seats;
  final BookingSnack snacks;
  final BookingCombo combos;

  const Ticket({
    required this.bookingId,
    required this.userId,
    required this.showing,
    required this.bookTime,
    required this.amount,
    required this.seats,
    required this.snacks,
    required this.combos,
  });
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      bookingId: json['bookingId'] as int,
      userId: json['userId'] as String,
      showing: Showing.fromJson(json['showing'] as Map<String, dynamic>),
      bookTime: DateTime.parse(json['bookTime'] as String),
      amount: json['amount'] as int,
      seats: BookingSeat.fromJson(json['seats'] as Map<String, dynamic>),
      snacks: BookingSnack.fromJson(json['snacks'] as Map<String, dynamic>),
      combos: BookingCombo.fromJson(json['combos'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'showing': showing.toJson(),
      'bookTime': bookTime.toIso8601String(),
      'amount': amount,
      'seats': seats.toJson(),
      'snacks': snacks.toJson(),
      'combos': combos.toJson(),
    };
  }
}
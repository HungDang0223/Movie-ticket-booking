import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';

class BookingSeat {
    final String showingId;
    final List<Seat> seats;

    const BookingSeat({
        required this.showingId,
        required this.seats,
    });
    factory BookingSeat.fromJson(Map<String, dynamic> json) {
        return BookingSeat(
            showingId: json['showingId'] as String,
            seats: (json['seats'] as List<dynamic>).map((e) => Seat.fromJson(e as Map<String, dynamic>)).toList(),
        );
    }
    Map<String, dynamic> toJson() {
        return {
            'showingId': showingId,
            'seats': seats.map((e) => e.toJson()).toList(),
        };
    }
}

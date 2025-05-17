import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../../data/models/seat.dart';

abstract class BookingSeatEvent extends Equatable {
  const BookingSeatEvent();

  @override
  List<Object?> get props => [];
}

class BookingLoadSeats extends BookingSeatEvent {
  final int showingId;

  const BookingLoadSeats(this.showingId);

  @override
  List<Object?> get props => [showingId];
}

class BookingSeatUpdated extends BookingSeatEvent {
  final Seat seat;

  const BookingSeatUpdated(this.seat);

  @override
  List<Object?> get props => [seat];
}

class BulkSeatsUpdated extends BookingSeatEvent {
  final List<Seat> seats;

  const BulkSeatsUpdated(this.seats);

  @override
  List<Object?> get props => [seats];
}

class ReserveSeat extends BookingSeatEvent {
  final int showingId;
  final int seatId;
  final int userId;

  const ReserveSeat({
    required this.showingId,
    required this.seatId,
    required this.userId,
  });

  @override
  List<Object?> get props => [showingId, seatId, userId];
}

class ConfirmSeatReservation extends BookingSeatEvent {
  final int showingId;
  final int seatId;
  final int userId;

  const ConfirmSeatReservation({
    required this.showingId,
    required this.seatId,
    required this.userId,
  });

  @override
  List<Object?> get props => [showingId, seatId, userId];
}

class CancelSeatReservation extends BookingSeatEvent {
  final int showingId;
  final int seatId;
  final int userId;

  const CancelSeatReservation({
    required this.showingId,
    required this.seatId,
    required this.userId,
  });

  @override
  List<Object?> get props => [showingId, seatId, userId];
}

class ConnectionStateChanged extends BookingSeatEvent {
  final ConnectionState connectionState;

  const ConnectionStateChanged(this.connectionState);

  @override
  List<Object?> get props => [connectionState];
}
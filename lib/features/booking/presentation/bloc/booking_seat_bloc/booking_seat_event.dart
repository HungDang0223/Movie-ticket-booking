import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../../data/models/seat.dart';

abstract class BookingSeatEvent extends Equatable {
  const BookingSeatEvent();

  @override
  List<Object?> get props => [];
}

class LoadSeatsEvent extends BookingSeatEvent {
  final int screenId;

  const LoadSeatsEvent(this.screenId);

  @override
  List<Object?> get props => [screenId];
}

class ConnectToRealtimeEvent extends BookingSeatEvent {
  final String websocketUrl;

  const ConnectToRealtimeEvent(this.websocketUrl);

  @override
  List<Object?> get props => [websocketUrl];
}

class JoinShowingEvent extends BookingSeatEvent {
  final int showingId;
  final String? userId;

  const JoinShowingEvent(this.showingId, {this.userId});

  @override
  List<Object?> get props => [showingId, userId];
}

class LeaveShowingEvent extends BookingSeatEvent {
  const LeaveShowingEvent();
}

class ReserveSeatEvent extends BookingSeatEvent {
  final ReserveSeatRequest request;

  const ReserveSeatEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ConfirmReservationEvent extends BookingSeatEvent {
  final ReserveSeatRequest request;

  const ConfirmReservationEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class CancelReservationEvent extends BookingSeatEvent {
  final ReserveSeatRequest request;

  const CancelReservationEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class SelectSeatEvent extends BookingSeatEvent {
  final int seatId;

  const SelectSeatEvent(this.seatId);

  @override
  List<Object?> get props => [seatId];
}

class DeselectSeatEvent extends BookingSeatEvent {
  final int seatId;

  const DeselectSeatEvent(this.seatId);

  @override
  List<Object?> get props => [seatId];
}

class ClearSelectedSeatsEvent extends BookingSeatEvent {
  const ClearSelectedSeatsEvent();
}

class SeatStatusUpdatedEvent extends BookingSeatEvent {
  final SeatStatusUpdate update;

  const SeatStatusUpdatedEvent(this.update);

  @override
  List<Object?> get props => [update];
}

class ConnectionStatusChangedEvent extends BookingSeatEvent {
  final String status;

  const ConnectionStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class DisconnectEvent extends BookingSeatEvent {
  const DisconnectEvent();
}
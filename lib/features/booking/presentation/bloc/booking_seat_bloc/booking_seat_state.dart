import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/models.dart';

abstract class BookingSeatState extends Equatable {
  const BookingSeatState();

  @override
  List<Object?> get props => [];
}

class BookingSeatInitial extends BookingSeatState {}

class BookingSeatLoading extends BookingSeatState {}

class BookingSeatLoaded extends BookingSeatState {
  final List<Seat> seats;
  final ConnectionState connectionState;

  const BookingSeatLoaded({
    required this.seats,
    this.connectionState = ConnectionState.done,
  });

  BookingSeatLoaded copyWith({
    List<Seat>? seats,
    ConnectionState? connectionState,
  }) {
    return BookingSeatLoaded(
      seats: seats ?? this.seats,
      connectionState: connectionState ?? this.connectionState,
    );
  }

  @override
  List<Object?> get props => [seats, connectionState];
}

class BookingSeatOperationInProgress extends BookingSeatState {}

class BookingSeatOperationSuccess extends BookingSeatState {
  final String message;

  const BookingSeatOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingSeatOperationFailure extends BookingSeatState {
  final String error;

  const BookingSeatOperationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
import 'package:flutter/material.dart';

import '../../data/models/models.dart';

abstract class BookingSeatRepository {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> joinShowing(int showingId);
  Future<void> leaveShowing(int showingId);
  Future<List<Seat>> loadInitialSeats(int showingId);
  Future<String> reserveSeat(int showingId, int seatId, int userId);
  Future<String> confirmSeatReservation(int showingId, int seatId, int userId);
  Future<String> cancelSeatReservation(int showingId, int seatId, int userId);
  Stream<ConnectionState> get connectionStateStream;
}
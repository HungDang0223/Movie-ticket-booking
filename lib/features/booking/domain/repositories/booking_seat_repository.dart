import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:movie_tickets/features/booking/data/models/showing_seat.dart';

abstract class BookingSeatRepository {
  Future<List<RowSeatsDto>> getSeatsByScreen(int screenId);
  Future<RegularResponse> reserveSeat(ReserveSeatRequest request);
  Future<RegularResponse> confirmReservation(ReserveSeatRequest request);
  Future<RegularResponse> cancelReservation(ReserveSeatRequest request);
  
  // WebSocket methods
  Future<void> connectToRealtimeUpdates(String websocketUrl);
  Future<void> joinShowing(int showingId, {String? userId});
  Future<void> leaveShowing();
  Stream<SeatStatusUpdate> get seatUpdates;
  Stream<String> get connectionStatus;
  void disconnect();
}
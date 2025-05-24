import 'package:movie_tickets/core/services/networking/websocket_service.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/booking/data/datasources/booking_seat_remote_data_source.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:movie_tickets/features/booking/data/models/showing_seat.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_seat_repository.dart';

class BookingSeatRepositoryImpl implements BookingSeatRepository {
  final BookingSeatRemoteDataSource _bookingSeatRemoteDataSource;
  final WebSocketService _webSocketService;

  BookingSeatRepositoryImpl({
    required BookingSeatRemoteDataSource apiService,
    required WebSocketService webSocketService,
  }) : _bookingSeatRemoteDataSource = apiService, _webSocketService = webSocketService;

  @override
  Future<List<RowSeatsDto>> getSeatsByScreen(int screenId) async {
    try {
      return await _bookingSeatRemoteDataSource.getSeatsByScreen(screenId);
    } catch (e) {
      throw Exception('Failed to get seats: $e');
    }
  }

  @override
  Future<RegularResponse> reserveSeat(ReserveSeatRequest request) async {
    try {
      return await _bookingSeatRemoteDataSource.reserveSeat(request);
    } catch (e) {
      throw Exception('Failed to reserve seat: $e');
    }
  }

  @override
  Future<RegularResponse> confirmReservation(ReserveSeatRequest request) async {
    try {
      return await _bookingSeatRemoteDataSource.confirmReservation(request);
    } catch (e) {
      throw Exception('Failed to confirm reservation: $e');
    }
  }

  @override
  Future<RegularResponse> cancelReservation(ReserveSeatRequest request) async {
    try {
      return await _bookingSeatRemoteDataSource.cancelReservation(request);
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  @override
  Future<void> connectToRealtimeUpdates(String websocketUrl) async {
    await _webSocketService.connect(websocketUrl);
  }

  @override
  Future<void> joinShowing(int showingId, {String? userId}) async {
    await _webSocketService.joinShowing(showingId, userId: userId);
  }

  @override
  Future<void> leaveShowing() async {
    await _webSocketService.leaveShowing();
  }

  @override
  Stream<SeatStatusUpdate> get seatUpdates => _webSocketService.seatUpdates;

  @override
  Stream<String> get connectionStatus => _webSocketService.connectionStatus;

  @override
  void disconnect() {
    _webSocketService.disconnect();
  }
}
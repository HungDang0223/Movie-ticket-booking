import 'dart:io';

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
      final response = await _bookingSeatRemoteDataSource.getSeatsByScreen(screenId);
      if (response.response.statusCode == HttpStatus.ok) {
        if (response.data.isEmpty) {
          throw Exception('No seats available for this screen.');
        }
        return response.data;
      } else {
        throw Exception('Failed to load seats: ${response.response.statusMessage}');
      }
  }

  @override
  Future<List<SeatStatusUpdate>> getSeatStatusesByShowing(int showingId) async {
    final response = await _bookingSeatRemoteDataSource.getSeatStatusesByShowing(showingId);
    if (response.response.statusCode == HttpStatus.ok) {
      return response.data;
    } else {
      throw Exception('Failed to load seat statuses: ${response.response.statusMessage}');
    }
  }

  @override
  Future<RegularResponse> reserveSeat(ReserveSeatRequest request) async {
    final response = await _bookingSeatRemoteDataSource.reserveSeat(request);
    if (response.response.statusCode == HttpStatus.ok) {
      return response.data;
    } else {
      throw Exception('Failed to reserve seat: ${response.response.statusMessage}');
    }
  }

  @override
  Future<RegularResponse> confirmReservation(ReserveSeatRequest request) async {
    try {
      final response = await _bookingSeatRemoteDataSource.confirmReservation(request);
      return response.data;
    } catch (e) {
      throw Exception('Failed to confirm reservation: $e');
    }
  }

  @override
  Future<RegularResponse> cancelReservation(ReserveSeatRequest request) async {
    try {
      final response = await _bookingSeatRemoteDataSource.cancelReservation(request);
      return response.data;
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  @override
  Future<RegularResponse> cancelAllReservations(CancelUserReservationRequest request) async {
    try {
      final response = await _bookingSeatRemoteDataSource.cancelAllReservations(request);
      return response.data;
    } catch (e) {
      throw Exception('Failed to cancel all reservations: $e');
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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_tickets/features/booking/data/datasources/booking_seat_remote_data_source.dart';
import 'package:movie_tickets/features/booking/data/models/showing_seat.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_seat_repository.dart';

import '../models/models.dart';

class BookingSeatRepositoryImpl extends BookingSeatRepository {
  final BookingSeatRemoteDataSource _seatService;
  
  // Stream controllers để phát các sự kiện
  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  final _seatUpdateController = StreamController<Seat>.broadcast();
  final _bulkSeatUpdateController = StreamController<List<Seat>>.broadcast();
  
  // Danh sách các subscriptions để hủy khi dispose
  final List<StreamSubscription> _subscriptions = [];

  BookingSeatRepositoryImpl({required BookingSeatRemoteDataSource seatService}) : _seatService = seatService {
    _setupListeners();
  }
  
  // Getters for streams
  Stream<ConnectionState> get onConnectionStateChange => _connectionStateController.stream;
  Stream<Seat> get onSeatUpdate => _seatUpdateController.stream;
  Stream<List<Seat>> get onBulkSeatUpdate => _bulkSeatUpdateController.stream;

  void _setupListeners() {
    _subscriptions.add(
      _seatService.onConnectionStateChange.listen((state) {
        _connectionStateController.add(state);
      })
    );
    
    _subscriptions.add(
      _seatService.onSeatUpdate.listen((seat) {
        _seatUpdateController.add(seat);
      })
    );
    
    _subscriptions.add(
      _seatService.onBulkSeatUpdate.listen((seats) {
        _bulkSeatUpdateController.add(seats);
      })
    );
  }
  
  // Kết nối tới WebSocket server
  @override
  Future<void> connect() async {
    return _seatService.connect();
  }
  
  // Ngắt kết nối WebSocket
  @override
  Future<void> disconnect() async {
    return _seatService.disconnect();
  }
  
  // Tham gia vào nhóm Showing
  @override
  Future<void> joinShowing(int showingId) async {
    return _seatService.joinShowing(showingId);
  }
  
  // Rời khỏi nhóm Showing
  @override
  Future<void> leaveShowing(int showingId) async {
    return _seatService.leaveShowing(showingId);
  }
  
  // Tải danh sách ghế ban đầu
  @override
  Future<List<Seat>> loadInitialSeats(int showingId) async {
    return _seatService.loadInitialSeats(showingId);
  }
  
  // Đặt ghế
  @override
  Future<String> reserveSeat(int showingId, int seatId, int userId) async {
    return _seatService.reserveSeat(showingId, seatId, userId);
  }
  
  // Xác nhận đặt ghế
  @override
  Future<String> confirmSeatReservation(int showingId, int seatId, int userId) async {
    return _seatService.confirmSeatReservation(showingId, seatId, userId);
  }
  
  // Hủy đặt ghế
  @override
  Future<String> cancelSeatReservation(int showingId, int seatId, int userId) async {
    return _seatService.cancelSeatReservation(showingId, seatId, userId);
  }
  
  // Dispose resources
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _connectionStateController.close();
    _seatUpdateController.close();
    _bulkSeatUpdateController.close();
  }
  
  @override
  // TODO: implement connectionStateStream
  Stream<ConnectionState> get connectionStateStream => _seatService.onConnectionStateChange;
}
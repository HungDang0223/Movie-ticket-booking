import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../models/models.dart';

class BookingSeatRemoteDataSource {
  
  WebSocketChannel? _channel;
  ConnectionState _connectionState = ConnectionState.none;
  
  // Stream controllers để phát ra các sự kiện
  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  final _seatUpdateController = StreamController<Seat>.broadcast();
  final _bulkSeatUpdateController = StreamController<List<Seat>>.broadcast();

  // Timeout cho các requests
  final Duration _requestTimeout;
  
  // Completer cho việc thiết lập kết nối
  Completer<void>? _connectionCompleter;
  
  // Map để lưu trữ các completer cho các request
  final Map<String, Completer<dynamic>> _requestCompleters = {};
  
  // Request ID counter
  int _requestId = 0;
  
  BookingSeatRemoteDataSource({
    Duration requestTimeout = const Duration(seconds: 10),
  })  : 
        _requestTimeout = requestTimeout;
  
  // Getters cho các streams
  Stream<ConnectionState> get onConnectionStateChange => _connectionStateController.stream;
  Stream<Seat> get onSeatUpdate => _seatUpdateController.stream;
  Stream<List<Seat>> get onBulkSeatUpdate => _bulkSeatUpdateController.stream;
  
  // Getter cho trạng thái kết nối hiện tại
  ConnectionState get connectionState => _connectionState;
  
  // Kết nối tới WebSocket server
  Future<void> connect() async {
    if (_connectionState == ConnectionState.active) {
      return;
    }
    
    if (_connectionCompleter != null) {
      return _connectionCompleter!.future;
    }
    
    _connectionCompleter = Completer<void>();
    
    try {
      _setConnectionState(ConnectionState.waiting);
      
      // Kết nối tới WebSocket server với token xác thực
      final uri = Uri.parse(baseURL);
      _channel = WebSocketChannel.connect(uri);
      
      // Lắng nghe các sự kiện từ server
      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleDisconnect,
        onError: _handleError,
        cancelOnError: false,
      );
      
      // Thiết lập ping để giữ kết nối
      _setupPingInterval();
      
      _setConnectionState(ConnectionState.active);
      _connectionCompleter!.complete();
    } catch (e) {
      _setConnectionState(ConnectionState.none);
      _connectionCompleter!.completeError(e);
      rethrow;
    } finally {
      _connectionCompleter = null;
    }
  }
  
  // Ngắt kết nối WebSocket
  Future<void> disconnect() async {
    _channel?.sink.close();
    _setConnectionState(ConnectionState.none);
  }
  
  // Thiết lập ping interval
  Timer? _pingTimer;
  void _setupPingInterval() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendPing();
    });
  }
  
  // Gửi ping để giữ kết nối
  void _sendPing() {
    if (_connectionState == ConnectionState.active) {
      _sendRawMessage({
        'type': 'ping',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
  
  // Xử lý các tin nhắn nhận được từ server
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final String type = data['type'];
      
      switch (type) {
        case 'pong':
          // Xử lý pong từ server (không cần làm gì)
          break;
        
        case 'seat_update':
          final seat = Seat.fromJson(data['seat']);
          _seatUpdateController.add(seat);
          break;
        
        case 'bulk_seat_update':
          final List<dynamic> seatsJson = data['seats'];
          final seats = seatsJson.map((json) => Seat.fromJson(json)).toList();
          _bulkSeatUpdateController.add(seats);
          break;
        
        case 'response':
          // Xử lý response từ các request
          final String requestId = data['requestId'];
          final completer = _requestCompleters.remove(requestId);
          
          if (completer != null) {
            if (data['error'] != null) {
              completer.completeError(data['error']);
            } else {
              completer.complete(data['result']);
            }
          }
          break;
        
        case 'error':
          // Xử lý lỗi chung
          print('WebSocket error: ${data['message']}');
          break;
        
        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }
  
  // Xử lý sự kiện mất kết nối
  void _handleDisconnect() {
    _pingTimer?.cancel();
    _setConnectionState(ConnectionState.none);
    
    // Thông báo lỗi cho tất cả các request đang chờ
    for (var completer in _requestCompleters.values) {
      if (!completer.isCompleted) {
        completer.completeError('WebSocket connection closed');
      }
    }
    _requestCompleters.clear();
  }
  
  // Xử lý lỗi kết nối
  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _setConnectionState(ConnectionState.none);
    
    // Tự động kết nối lại sau một khoảng thời gian
    Timer(const Duration(seconds: 5), () {
      if (_connectionState == ConnectionState.none) {
        connect();
      }
    });
  }
  
  // Cập nhật trạng thái kết nối và thông báo
  void _setConnectionState(ConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }
  
  // Gửi tin nhắn raw tới server
  void _sendRawMessage(Map<String, dynamic> message) {
    if (_connectionState != ConnectionState.active) {
      throw Exception('WebSocket không kết nối');
    }
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  // Gửi request tới server và chờ phản hồi
  Future<dynamic> _sendRequest(String action, Map<String, dynamic> params) async {
    if (_connectionState != ConnectionState.active) {
      throw Exception('WebSocket không kết nối');
    }
    
    final requestId = (++_requestId).toString();
    final completer = Completer<dynamic>();
    _requestCompleters[requestId] = completer;
    
    // Thiết lập timeout
    final timeout = Timer(_requestTimeout, () {
      final reqCompleter = _requestCompleters.remove(requestId);
      if (reqCompleter != null && !reqCompleter.isCompleted) {
        reqCompleter.completeError('Request timeout');
      }
    });
    
    // Gửi request
    _sendRawMessage({
      'type': 'request',
      'requestId': requestId,
      'action': action,
      'params': params,
    });
    
    try {
      return await completer.future;
    } finally {
      timeout.cancel();
    }
  }
  
  // Tham gia vào nhóm Showing
  Future<void> joinShowing(int showingId) async {
    await _sendRequest('join_Showing', {'showingId': showingId});
  }
  
  // Rời khỏi nhóm Showing
  Future<void> leaveShowing(int showingId) async {
    await _sendRequest('leave_Showing', {'showingId': showingId});
  }
  
  // Lấy danh sách ghế ban đầu cho một buổi chiếu
  Future<List<Seat>> loadInitialSeats(int showingId) async {
    final result = await _sendRequest('get_seats', {'showingId': showingId});
    final List<dynamic> seatsJson = result['seats'];
    return seatsJson.map((json) => Seat.fromJson(json)).toList();
  }
  
  // Đặt chỗ tạm thời
  Future<String> reserveSeat(int showingId, int seatId, int userId) async {
    final result = await _sendRequest('reserve_seat', {
      'showingId': showingId,
      'seatId': seatId,
      'userId': userId,
    });
    return result['message'];
  }
  
  // Xác nhận đặt chỗ
  Future<String> confirmSeatReservation(int showingId, int seatId, int userId) async {
    final result = await _sendRequest('confirm_reservation', {
      'showingId': showingId,
      'seatId': seatId,
      'userId': userId,
    });
    return result['message'];
  }
  
  // Hủy đặt chỗ
  Future<String> cancelSeatReservation(int showingId, int seatId, int userId) async {
    final result = await _sendRequest('cancel_reservation', {
      'showingId': showingId,
      'seatId': seatId,
      'userId': userId,
    });
    return result['message'];
  }
  
  // Giải phóng tài nguyên
  void dispose() {
    _channel?.sink.close();
    _pingTimer?.cancel();
    _connectionStateController.close();
    _seatUpdateController.close();
    _bulkSeatUpdateController.close();
  }
  
}
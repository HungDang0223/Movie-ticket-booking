import 'dart:async';
import 'dart:convert';
import 'package:movie_tickets/core/constants/enums.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<SeatStatusUpdate>? _seatUpdateController;
  StreamController<String>? _connectionStatusController;
  String? _connectionId;
  int? _currentShowingId;
  String? _userId;

  Stream<SeatStatusUpdate> get seatUpdates => _seatUpdateController?.stream ?? const Stream.empty();
  Stream<String> get connectionStatus => _connectionStatusController?.stream ?? const Stream.empty();

  bool get isConnected => _channel != null && _channel!.closeCode == null;

  Future<void> connect(String websocketUrl) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
      _seatUpdateController = StreamController<SeatStatusUpdate>.broadcast();
      _connectionStatusController = StreamController<String>.broadcast();

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _connectionStatusController?.add('connected');
    } catch (e) {
      _connectionStatusController?.add('error: $e');
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final messageType = data['type'] as String?;

      switch (messageType) {
        case 'connected':
          _connectionId = data['connectionId'] as String?;
          _connectionStatusController?.add('connected');
          break;
        
        case 'seatStatusUpdate':
          final update = SeatStatusUpdate(
            seatId: data['seatId'] as int,
            status: _parseStatus(data['status'] as String),
            reservedBy: data['reservedBy'] as String?,
            reservationExpiresAt: data['reservationExpiresAt'] != null 
                ? DateTime.parse(data['reservationExpiresAt'] as String)
                : null,
          );
          _seatUpdateController?.add(update);
          break;

        case 'bulkSeatStatusUpdate':
          final updates = (data['updates'] as List).map((updateData) {
            return SeatStatusUpdate(
              seatId: updateData['seatId'] as int,
              status: _parseStatus(updateData['status'] as String),
              reservedBy: updateData['reservedBy'] as String?,
              reservationExpiresAt: updateData['reservationExpiresAt'] != null 
                  ? DateTime.parse(updateData['reservationExpiresAt'] as String)
                  : null,
            );
          }).toList();
          
          for (final update in updates) {
            _seatUpdateController?.add(update);
          }
          break;

        case 'error':
          _connectionStatusController?.add('error: ${data['message']}');
          break;

        case 'pong':
          // Handle ping response
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  SeatStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return SeatStatus.Available;
      case 'reserved':
        return SeatStatus.Reserved;
      case 'sold':
        return SeatStatus.Sold;
      default:
        return SeatStatus.Available;
    }
  }

  void _handleError(error) {
    _connectionStatusController?.add('error: $error');
  }

  void _handleDisconnection() {
    _connectionStatusController?.add('disconnected');
  }

  Future<void> joinShowing(int showingId, {String? userId}) async {
    if (!isConnected) throw Exception('WebSocket not connected');

    _currentShowingId = showingId;
    _userId = userId;

    final message = {
      'type': 'joinShowing',
      'showingId': showingId,
      if (userId != null) 'userId': userId,
    };

    _channel?.sink.add(jsonEncode(message));
  }

  Future<void> leaveShowing() async {
    if (!isConnected) return;

    final message = {
      'type': 'leaveShowing',
    };

    _channel?.sink.add(jsonEncode(message));
    _currentShowingId = null;
  }

  void sendPing() {
    if (!isConnected) return;

    final message = {
      'type': 'ping',
    };

    _channel?.sink.add(jsonEncode(message));
  }

  Future<void> disconnect() async {
    await _channel?.sink.close(status.goingAway);
    _seatUpdateController?.close();
    _connectionStatusController?.close();
    _channel = null;
    _seatUpdateController = null;
    _connectionStatusController = null;
    _connectionId = null;
    _currentShowingId = null;
    _userId = null;
  }
}
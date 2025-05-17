import 'package:movie_tickets/core/constants/enums.dart';

class Seat {
  final int seatId;
  final String seatType;
  final String screenName;
  final String rowName;
  final String seatNumber;
  String get seatName => rowName + seatNumber;
  final int showingId;
  final SeatStatus status; // ENUM('Available', 'TemporarilyReserved', 'Reserved', 'Sold')
  final String? reservedBy; // userId
  final DateTime? reservedAt;
  final DateTime? reservationExpiresAt;
  final double? price;
  const Seat({
    required this.seatId,
    required this.seatType,
    required this.screenName,
    required this.rowName,
    required this.seatNumber,
    required this.showingId,
    this.status = SeatStatus.Available,
    this.reservedBy,
    this.reservedAt,
    this.reservationExpiresAt,
    this.price,
  });
  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatId: json['seatId'] as int,
      seatType: json['seatType'] as String,
      screenName: json['screenName'] as String,
      rowName: json['rowName'] as String,
      seatNumber: json['seatNumber'] as String,
      showingId: json['showingId'] as int,
      status: SeatStatus.values.firstWhere((e) => e.toString() == 'SeatStatus.${json['status']}'),
      reservedBy: json['reservedBy'] as String?,
      reservedAt: json['reservedAt'] as DateTime?,
      reservationExpiresAt: json['reservationExpiresAt'] as DateTime?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'seatId': seatId,
      'seatType': seatType,
      'screenName': screenName,
      'rowName': rowName,
      'seatNumber': seatNumber,
      'showingId': showingId,
      'status': status.toString().split('.').last,
      'reservedBy': reservedBy,
      'reservedAt': reservedAt,
      'reservationExpiresAt': reservationExpiresAt,
      'price': price,
    };
  }
}
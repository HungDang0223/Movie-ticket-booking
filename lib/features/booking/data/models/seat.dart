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

class SetDto {
  final int seatId;
  final int seatNumber;
  const SetDto({
    required this.seatId,
    required this.seatNumber,
  });
  factory SetDto.fromJson(Map<String, dynamic> json) {
    return SetDto(
      seatId: json['seatId'] as int,
      seatNumber: json['seatNumber'] as int,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'seatId': seatId,
      'seatNumber': seatNumber,
    };
  }
}

class RowSeatsDto {
  final String rowName;
  final String seatType;
  final List<SetDto> seats;
  const RowSeatsDto({
    required this.rowName,
    required this.seatType,
    required this.seats,
  });
  factory RowSeatsDto.fromJson(Map<String, dynamic> json) {
    return RowSeatsDto(
      rowName: json['rowName'] as String,
      seatType: json['seatType'] as String,
      seats: (json['seats'] as List<dynamic>)
          .map((e) => SetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'rowName': rowName,
      'seatType': seatType,
      'seats': seats.map((e) => e.toJson()).toList(),
    };
  }
}

class SeatStatusUpdate {
  final int seatId;
  final SeatStatus status; // ENUM('Available', 'TemporarilyReserved', 'Reserved', 'Sold')
  final String? reservedBy; // userId
  final DateTime? reservationExpiresAt;

  const SeatStatusUpdate({
    required this.seatId,
    required this.status,
    this.reservedBy,
    this.reservationExpiresAt,
  });

  factory SeatStatusUpdate.fromJson(Map<String, dynamic> json) {
    return SeatStatusUpdate(
      seatId: json['seatId'] as int,
      status: SeatStatus.values.firstWhere((e) => e.toString() == 'SeatStatus.${json['status']}'),
      reservedBy: json['reservedBy'] as String?,
      reservationExpiresAt: json['reservationExpiresAt'] != null ? DateTime.parse(json['reservationExpiresAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatId': seatId,
      'status': status.toString().split('.').last,
      'reservedBy': reservedBy,
      'reservationExpiresAt': reservationExpiresAt?.toIso8601String(),
    };
  }
}
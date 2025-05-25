class ShowingSeat {
  final int id;
  final int showingId;
  final int seatId;
  final String status; // ENUM('Available', 'TemporarilyReserved', 'Reserved', 'Sold')
  final String? reservedBy; // userId
  final DateTime? reservedAt;
  final DateTime? reservationExpiresAt;
  const ShowingSeat({
    required this.id,
    required this.showingId,
    required this.seatId,
    required this.status,
    this.reservedBy,
    this.reservedAt,
    this.reservationExpiresAt,
  });
  factory ShowingSeat.fromJson(Map<String, dynamic> json) {
    return ShowingSeat(
      id: json['id'] as int,
      showingId: json['showingId'] as int,
      seatId: json['seatId'] as int,
      status: json['status'] as String,
      reservedBy: json['reservedBy'] as String?,
      reservedAt: json['reservedAt'] != null
          ? DateTime.parse(json['reservedAt'] as String)
          : null,
      reservationExpiresAt: json['reservationExpiresAt'] != null
          ? DateTime.parse(json['reservationExpiresAt'] as String)
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showingId': showingId,
      'seatId': seatId,
      'status': status,
      'reservedBy': reservedBy,
      'reservedAt': reservedAt?.toIso8601String(),
      'reservationExpiresAt': reservationExpiresAt?.toIso8601String(),
    };
  }
}

// ENUM('Available', 'TemporarilyReserved', 'Reserved', 'Sold')

class ReserveSeatRequest {
  final int showingId;
  final int seatId;

  ReserveSeatRequest({
    required this.showingId,
    required this.seatId,
  });

  Map<String, dynamic> toJson() {
    return {
      'showingId': showingId,
      'seatId': seatId,
    };
  }
}
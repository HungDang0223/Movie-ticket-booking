class Seat {
  final int seatId;
  final String seatType;
  final String screenName;
  final String rowName;
  final String seatNumber;
  String get seatName => rowName + seatNumber;
  const Seat({
    required this.seatId,
    required this.seatType,
    required this.screenName,
    required this.rowName,
    required this.seatNumber,
  });
  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatId: json['seatId'] as int,
      seatType: json['seatType'] as String,
      screenName: json['screenName'] as String,
      rowName: json['rowName'] as String,
      seatNumber: json['seatNumber'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'seatId': seatId,
      'seatType': seatType,
      'screenName': screenName,
      'rowName': rowName,
      'seatNumber': seatNumber,
    };
  }
}
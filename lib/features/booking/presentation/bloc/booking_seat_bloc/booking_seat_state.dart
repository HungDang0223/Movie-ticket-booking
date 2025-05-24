import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';

enum BookingSeatStatus {
  initial,
  loading,
  loaded,
  reserving,
  reserved,
  confirming,
  confirmed,
  canceling,
  error
}

class BookingSeatState extends Equatable {
  final BookingSeatStatus status;
  final List<RowSeatsDto> rowSeats;
  final List<int> selectedSeats;
  final Map<int, SeatStatusUpdate> seatStatusUpdates;
  final String? connectionStatus;
  final int? currentShowingId;
  final String? errorMessage;

  const BookingSeatState({
    this.status = BookingSeatStatus.initial,
    this.rowSeats = const [],
    this.selectedSeats = const [],
    this.seatStatusUpdates = const {},
    this.connectionStatus,
    this.currentShowingId,
    this.errorMessage,
  });

  BookingSeatState copyWith({
    BookingSeatStatus? status,
    List<RowSeatsDto>? rowSeats,
    List<int>? selectedSeats,
    Map<int, SeatStatusUpdate>? seatStatusUpdates,
    String? connectionStatus,
    int? currentShowingId,
    String? errorMessage,
  }) {
    return BookingSeatState(
      status: status ?? this.status,
      rowSeats: rowSeats ?? this.rowSeats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      seatStatusUpdates: seatStatusUpdates ?? this.seatStatusUpdates,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentShowingId: currentShowingId ?? this.currentShowingId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rowSeats,
        selectedSeats,
        seatStatusUpdates,
        connectionStatus,
        currentShowingId,
        errorMessage,
      ];
}

class BookingSeatInitial extends BookingSeatState {
  const BookingSeatInitial() : super();
}
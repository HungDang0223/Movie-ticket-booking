import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';

enum BookingSeatStatus {
  initial,
  loading,
  loaded,
  empty,
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
  final bool hasNewError; // Add this flag to track new errors

  const BookingSeatState({
    this.status = BookingSeatStatus.initial,
    this.rowSeats = const [],
    this.selectedSeats = const [],
    this.seatStatusUpdates = const {},
    this.connectionStatus,
    this.currentShowingId,
    this.errorMessage,
    this.hasNewError = false, // Default to false
  });

  BookingSeatState copyWith({
    BookingSeatStatus? status,
    List<RowSeatsDto>? rowSeats,
    List<int>? selectedSeats,
    Map<int, SeatStatusUpdate>? seatStatusUpdates,
    String? connectionStatus,
    int? currentShowingId,
    String? errorMessage,
    bool? hasNewError,
    bool clearError = false, // Add flag to clear error
  }) {
    return BookingSeatState(
      status: status ?? this.status,
      rowSeats: rowSeats ?? this.rowSeats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      seatStatusUpdates: seatStatusUpdates ?? this.seatStatusUpdates,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentShowingId: currentShowingId ?? this.currentShowingId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasNewError: hasNewError ?? (clearError ? false : this.hasNewError),
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
        hasNewError,
      ];
}

class BookingSeatInitial extends BookingSeatState {
  const BookingSeatInitial() : super();
}
import 'package:equatable/equatable.dart';
import 'package:movie_tickets/core/constants/enums.dart';
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

enum SeatLayoutStatus {
  initial,
  loading,
  loaded,
  error
}

enum SeatStatusLoadingState {
  initial,
  loading,
  loaded,
  error
}

class BookingSeatState extends Equatable {
  // Main booking status
  final BookingSeatStatus status;
  
  // Seat layout data and loading state
  final SeatLayoutStatus seatLayoutStatus;
  final List<RowSeatsDto> rowSeats;
  
  // Seat status data and loading state
  final SeatStatusLoadingState seatStatusLoadingState;
  // return list of current seat statuses from showing -> list of SeatStatusUpdate
  final List<SeatStatusUpdate> currentSeatStatuses;
  final List<SeatStatusUpdate> seatStatusUpdates;  // Real-time updates

  // User selections
  final List<int> selectedSeats;
  
  // WebSocket connection
  final String? connectionStatus;
  final int? currentShowingId;
  
  // Error handling
  final String? errorMessage;
  final bool hasNewError;

  const BookingSeatState({
    this.status = BookingSeatStatus.initial,
    this.seatLayoutStatus = SeatLayoutStatus.initial,
    this.rowSeats = const [],
    this.seatStatusLoadingState = SeatStatusLoadingState.initial,
    this.currentSeatStatuses = const [],
    // Initialize with an empty map to avoid null checks later
    this.seatStatusUpdates = const [],
    // Initialize with an empty map to avoid null checks later
    this.selectedSeats = const [],
    this.connectionStatus,
    this.currentShowingId,
    this.errorMessage,
    this.hasNewError = false,
  });

  BookingSeatState copyWith({
    BookingSeatStatus? status,
    SeatLayoutStatus? seatLayoutStatus,
    List<RowSeatsDto>? rowSeats,
    SeatStatusLoadingState? seatStatusLoadingState,
    List<SeatStatusUpdate>? currentSeatStatuses,
    List<SeatStatusUpdate>? seatStatusUpdates,
    List<int>? selectedSeats,
    String? connectionStatus,
    int? currentShowingId,
    String? errorMessage,
    bool? hasNewError,
    bool clearError = false,
  }) {
    return BookingSeatState(
      status: status ?? this.status,
      seatLayoutStatus: seatLayoutStatus ?? this.seatLayoutStatus,
      rowSeats: rowSeats ?? this.rowSeats,
      seatStatusLoadingState: seatStatusLoadingState ?? this.seatStatusLoadingState,
      currentSeatStatuses: currentSeatStatuses ?? this.currentSeatStatuses,
      seatStatusUpdates: seatStatusUpdates ?? this.seatStatusUpdates,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentShowingId: currentShowingId ?? this.currentShowingId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasNewError: hasNewError ?? (clearError ? false : this.hasNewError),
    );
  }

  // Helper method to get the effective seat status for a seat
  SeatStatus getEffectiveSeatStatus(int seatId) {
  // Real-time updates take precedence over current statuses
  if (seatStatusUpdates.isNotEmpty) {
    try {
      final update = seatStatusUpdates.firstWhere(
        (update) => update.seatId == seatId,
      );
      return update.status;
    } catch (e) {
      // No real-time update found, continue to check current statuses
    }
  }
  
  // Fall back to current seat status from showing
  if (currentSeatStatuses.isNotEmpty) {
    try {
      final currentStatus = currentSeatStatuses.firstWhere(
        (status) => status.seatId == seatId,
      );
      return currentStatus.status;
    } catch (e) {
      // No current status found, default to available
    }
  }
  
  return SeatStatus.Available;
}

  // Helper method to check if a seat is bookable
  bool isSeatBookable(int seatId) {
  final status = getEffectiveSeatStatus(seatId);
  // A seat is bookable if it's available or if it's selected by the current user
  return status == SeatStatus.Available || selectedSeats.contains(seatId);
}

  // Helper method to check if all required data is loaded
  bool get isDataReady => 
    seatLayoutStatus == SeatLayoutStatus.loaded && 
    seatStatusLoadingState == SeatStatusLoadingState.loaded;

  @override
  List<Object?> get props => [
        status,
        seatLayoutStatus,
        rowSeats.length,
        seatStatusLoadingState,
        currentSeatStatuses.length,
        seatStatusUpdates.length,
        selectedSeats,
        connectionStatus,
        currentShowingId,
        errorMessage,
        hasNewError,
      ];
}

class BookingSeatInitial extends BookingSeatState {
  const BookingSeatInitial() : super();
}
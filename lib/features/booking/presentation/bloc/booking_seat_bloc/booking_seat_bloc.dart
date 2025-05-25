import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/enums.dart';
import 'package:movie_tickets/features/booking/data/models/showing_seat.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_seat_repository.dart';

import '../../../data/models/seat.dart';
import 'booking_seat_event.dart';
import 'booking_seat_state.dart';

class BookingSeatBloc extends Bloc<BookingSeatEvent, BookingSeatState> {
  final BookingSeatRepository _repository;
  StreamSubscription<SeatStatusUpdate>? _seatUpdatesSubscription;
  StreamSubscription<String>? _connectionStatusSubscription;

  BookingSeatBloc({required BookingSeatRepository repository})
      : _repository = repository,
        super(const BookingSeatInitial()) {
    on<LoadSeatsEvent>(_onLoadSeats);
    on<LoadSeatStatusesEvent>(_onLoadSeatStatuses);
    on<ConnectToRealtimeEvent>(_onConnectToRealtime);
    on<JoinShowingEvent>(_onJoinShowing);
    on<LeaveShowingEvent>(_onLeaveShowing);
    on<ReserveSeatEvent>(_onReserveSeat);
    on<ConfirmReservationEvent>(_onConfirmReservation);
    on<CancelReservationEvent>(_onCancelReservation);
    on<SelectSeatEvent>(_onSelectSeat);
    on<DeselectSeatEvent>(_onDeselectSeat);
    on<ClearSelectedSeatsEvent>(_onClearSelectedSeats);
    on<SeatStatusUpdatedEvent>(_onSeatStatusUpdated);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    on<CleanupUserReservedSeatsEvent>(_onCleanupUserReservedSeats);
    on<ReleaseUserSeatsEvent>(_onReleaseUserSeats);
    on<DisconnectEvent>(_onDisconnect);
    on<ClearErrorEvent>(_onClearError);
  }

  Future<void> _onLoadSeats(LoadSeatsEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.loading, clearError: true));
    try {
      final rowSeats = await _repository.getSeatsByScreen(event.screenId);
      if (rowSeats.isEmpty) {
        emit(state.copyWith(
          status: BookingSeatStatus.empty,
          errorMessage: 'No seats available for this screen.',
          hasNewError: true,
        ));
        return;
      }
      emit(state.copyWith(
        status: BookingSeatStatus.loaded,
        rowSeats: rowSeats,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: 'Failed to load seats: $e',
        hasNewError: true,
      ));
    }
  }

  Future<void> _onLoadSeatStatuses(LoadSeatStatusesEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(
      seatStatusLoadingState: SeatStatusLoadingState.loading,
      clearError: true
    ));
    
    try {
      // You need to implement this method in your repository
      final seatStatuses = await _repository.getSeatStatusesByShowing(event.showingId);
      print('Loaded seat statuses: ${seatStatuses.length}');
      emit(state.copyWith(
        seatStatusLoadingState: SeatStatusLoadingState.loaded,
        currentSeatStatuses: seatStatuses,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        seatStatusLoadingState: SeatStatusLoadingState.error,
        errorMessage: 'Failed to load seat statuses: $e',
        hasNewError: true,
      ));
    }
  }

  Future<void> _onConnectToRealtime(ConnectToRealtimeEvent event, Emitter<BookingSeatState> emit) async {
    try {
      await _repository.connectToRealtimeUpdates(event.websocketUrl);
      
      // Listen to seat updates
      _seatUpdatesSubscription?.cancel();
      _seatUpdatesSubscription = _repository.seatUpdates.listen(
        (update) => add(SeatStatusUpdatedEvent(update)),
      );

      // Listen to connection status
      _connectionStatusSubscription?.cancel();
      _connectionStatusSubscription = _repository.connectionStatus.listen(
        (status) => add(ConnectionStatusChangedEvent(status)),
      );

      emit(state.copyWith(
        connectionStatus: 'connecting',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: 'error',
        errorMessage: 'Failed to connect to realtime updates: $e',
        hasNewError: true,
      ));
    }
  }

  Future<void> _onJoinShowing(JoinShowingEvent event, Emitter<BookingSeatState> emit) async {
    try {
      await _repository.joinShowing(event.showingId, userId: event.userId);
      emit(state.copyWith(
        currentShowingId: event.showingId,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to join showing: $e',
        hasNewError: true,
      ));
    }
  }

  Future<void> _onLeaveShowing(LeaveShowingEvent event, Emitter<BookingSeatState> emit) async {
    try {
      await _repository.leaveShowing();
      emit(state.copyWith(
        currentShowingId: null,
        selectedSeats: [],
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to leave showing: $e',
        hasNewError: true,
      ));
    }
  }

  Future<void> _onReserveSeat(ReserveSeatEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.reserving, clearError: true));
    
    try {
      final response = await _repository.reserveSeat(event.request);
      if (response.status == 'success') {
        emit(state.copyWith(
          status: BookingSeatStatus.reserved,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: BookingSeatStatus.error,
          errorMessage: response.message,
          hasNewError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
        hasNewError: true,
      ));
    }
  }

  Future<void> _onConfirmReservation(ConfirmReservationEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.confirming, clearError: true));
    
    try {
      final response = await _repository.confirmReservation(event.request);
      if (response.status == 'success') {
        emit(state.copyWith(
          status: BookingSeatStatus.confirmed,
          selectedSeats: [], // Clear selected seats after confirmation
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: BookingSeatStatus.error,
          errorMessage: response.message ?? 'Failed to confirm reservation',
          hasNewError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
        hasNewError: true,
      ));
    }
  }

  Future<void> _onCancelReservation(CancelReservationEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.canceling, clearError: true));
    
    try {
      final response = await _repository.cancelReservation(event.request);
      if (response.status == 'success') {
        emit(state.copyWith(
          status: BookingSeatStatus.loaded,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: BookingSeatStatus.error,
          errorMessage: response.message ?? 'Failed to cancel reservation',
          hasNewError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
        hasNewError: true,
      ));
    }
  }

  void _onSelectSeat(SelectSeatEvent event, Emitter<BookingSeatState> emit) {
    final currentSelected = List<int>.from(state.selectedSeats);
    if (!currentSelected.contains(event.seatId)) {
      currentSelected.add(event.seatId);
      emit(state.copyWith(selectedSeats: currentSelected, clearError: true));
    }
  }

  void _onDeselectSeat(DeselectSeatEvent event, Emitter<BookingSeatState> emit) {
    final currentSelected = List<int>.from(state.selectedSeats);
    currentSelected.remove(event.seatId);
    emit(state.copyWith(selectedSeats: currentSelected, clearError: true));
  }

  void _onClearSelectedSeats(ClearSelectedSeatsEvent event, Emitter<BookingSeatState> emit) {
    emit(state.copyWith(selectedSeats: [], clearError: true));
  }

  void _onSeatStatusUpdated(SeatStatusUpdatedEvent event, Emitter<BookingSeatState> emit) {
  print('Received seat status update: seatId=${event.update.seatId}, status=${event.update.status}');
  
  // Update the current seat statuses list (this is the source of truth)
  final updatedCurrentSeatStatuses = List<SeatStatusUpdate>.from(state.currentSeatStatuses);
  final currentIndex = updatedCurrentSeatStatuses.indexWhere((status) => status.seatId == event.update.seatId);
  
  if (currentIndex != -1) {
    updatedCurrentSeatStatuses[currentIndex] = event.update;
  } else {
    updatedCurrentSeatStatuses.add(event.update);
  }

  // Also update the real-time updates list for immediate UI response
  final updatedSeatUpdates = List<SeatStatusUpdate>.from(state.seatStatusUpdates);
  final updateIndex = updatedSeatUpdates.indexWhere((update) => update.seatId == event.update.seatId);
  
  if (updateIndex != -1) {
    updatedSeatUpdates[updateIndex] = event.update;
  } else {
    updatedSeatUpdates.add(event.update);
  }

  // If a seat that was selected by the user gets reserved/sold by someone else,
  // remove it from selected seats
  if (event.update.status != SeatStatus.Available && 
      state.selectedSeats.contains(event.update.seatId)) {
    final updatedSelectedSeats = List<int>.from(state.selectedSeats);
    updatedSelectedSeats.remove(event.update.seatId);
    
    emit(state.copyWith(
      currentSeatStatuses: updatedCurrentSeatStatuses,
      seatStatusUpdates: updatedSeatUpdates,
      selectedSeats: updatedSelectedSeats,
    ));
  } else {
    emit(state.copyWith(
      currentSeatStatuses: updatedCurrentSeatStatuses,
      seatStatusUpdates: updatedSeatUpdates,
    ));
  }
}

Future<void> _onCleanupUserReservedSeats(
    CleanupUserReservedSeatsEvent event, 
    Emitter<BookingSeatState> emit
  ) async {
    try {
      print('Cleaning up reserved seats for user: ${event.seatId} in showing ${event.showingId}');
      
      final response = await _repository.cancelReservation(
        ReserveSeatRequest(
          showingId: event.showingId,
          seatId: event.seatId,
        ),
      );
      
      if (response.status == 'success') {
        print('Successfully released user reserved seats');
        
        // Clear selected seats from local state
        emit(state.copyWith(
          selectedSeats: [],
          clearError: true,
        ));
      } else {
        print('Failed to release seats: ${response.message}');
        emit(state.copyWith(
          errorMessage: 'Failed to release reserved seats: ${response.message}',
          hasNewError: true,
        ));
      }
    } catch (e) {
      print('Error releasing user reserved seats: $e');
      emit(state.copyWith(
        errorMessage: 'Error releasing reserved seats: $e',
        hasNewError: true,
      ));
    }
  }

  Future<void> _onReleaseUserSeats(
    ReleaseUserSeatsEvent event, 
    Emitter<BookingSeatState> emit
  ) async {
    try {
      print('Releasing specific seats: ${event.userId}');
      
      final response = await _repository.cancelAllReservations(
        CancelUserReservationRequest(
          showingId: event.showingId,
          userId: event.userId,
        ),
      );

      if (response.status == 'success') {
        print('Successfully released specific seats');
        
        // Remove released seats from selected seats
        state.selectedSeats.clear();
        
        emit(state.copyWith(
          selectedSeats: [],
          clearError: true,
        ));
      } else {
        print('Failed to release specific seats: ${response.message}');
      }
    } catch (e) {
      print('Error releasing specific seats: $e');
    }
  }

  void _onConnectionStatusChanged(ConnectionStatusChangedEvent event, Emitter<BookingSeatState> emit) {
    emit(state.copyWith(connectionStatus: event.status));
  }

  void _onClearError(ClearErrorEvent event, Emitter<BookingSeatState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onDisconnect(DisconnectEvent event, Emitter<BookingSeatState> emit) {
    _repository.disconnect();
    _seatUpdatesSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    
    emit(state.copyWith(
      connectionStatus: 'disconnected',
      currentShowingId: null,
      selectedSeats: [],
      seatStatusUpdates: [],
      clearError: true,
    ));
  }

  @override
  Future<void> close() {
    _seatUpdatesSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _repository.disconnect();
    return super.close();
  }
}
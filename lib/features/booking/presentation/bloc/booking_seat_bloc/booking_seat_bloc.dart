import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<DisconnectEvent>(_onDisconnect);
  }

  Future<void> _onLoadSeats(LoadSeatsEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.loading));
    
    try {
      final rowSeats = await _repository.getSeatsByScreen(event.screenId);
      emit(state.copyWith(
        status: BookingSeatStatus.loaded,
        rowSeats: rowSeats,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
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
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: 'error',
        errorMessage: 'Failed to connect to realtime updates: $e',
      ));
    }
  }

  Future<void> _onJoinShowing(JoinShowingEvent event, Emitter<BookingSeatState> emit) async {
    try {
      await _repository.joinShowing(event.showingId, userId: event.userId);
      emit(state.copyWith(
        currentShowingId: event.showingId,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to join showing: $e',
      ));
    }
  }

  Future<void> _onLeaveShowing(LeaveShowingEvent event, Emitter<BookingSeatState> emit) async {
    try {
      await _repository.leaveShowing();
      emit(state.copyWith(
        currentShowingId: null,
        selectedSeats: [],
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to leave showing: $e',
      ));
    }
  }

  Future<void> _onReserveSeat(ReserveSeatEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.reserving));
    
    try {
      final response = await _repository.reserveSeat(event.request);
      if (response.status == 'success') {
        emit(state.copyWith(
          status: BookingSeatStatus.reserved,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: BookingSeatStatus.error,
          errorMessage: response.message ?? 'Failed to reserve seat',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onConfirmReservation(ConfirmReservationEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.confirming));
    
    try {
      final response = await _repository.confirmReservation(event.request);
      if (response.status == 'success') {
        emit(state.copyWith(
          status: BookingSeatStatus.confirmed,
          selectedSeats: [], // Clear selected seats after confirmation
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: BookingSeatStatus.error,
          errorMessage: response.message ?? 'Failed to confirm reservation',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelReservation(CancelReservationEvent event, Emitter<BookingSeatState> emit) async {
    emit(state.copyWith(status: BookingSeatStatus.canceling));
    
    try {
      final response = await _repository.cancelReservation(event.request);
      if (response.status == 'success') {
        emit(state.copyWith(
          status: BookingSeatStatus.loaded,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: BookingSeatStatus.error,
          errorMessage: response.message ?? 'Failed to cancel reservation',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingSeatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectSeat(SelectSeatEvent event, Emitter<BookingSeatState> emit) {
    final currentSelected = List<int>.from(state.selectedSeats);
    if (!currentSelected.contains(event.seatId)) {
      currentSelected.add(event.seatId);
      emit(state.copyWith(selectedSeats: currentSelected));
    }
  }

  void _onDeselectSeat(DeselectSeatEvent event, Emitter<BookingSeatState> emit) {
    final currentSelected = List<int>.from(state.selectedSeats);
    currentSelected.remove(event.seatId);
    emit(state.copyWith(selectedSeats: currentSelected));
  }

  void _onClearSelectedSeats(ClearSelectedSeatsEvent event, Emitter<BookingSeatState> emit) {
    emit(state.copyWith(selectedSeats: []));
  }

  void _onSeatStatusUpdated(SeatStatusUpdatedEvent event, Emitter<BookingSeatState> emit) {
    final updatedSeatUpdates = Map<int, SeatStatusUpdate>.from(state.seatStatusUpdates);
    updatedSeatUpdates[event.update.seatId] = event.update;
    
    emit(state.copyWith(seatStatusUpdates: updatedSeatUpdates));
  }

  void _onConnectionStatusChanged(ConnectionStatusChangedEvent event, Emitter<BookingSeatState> emit) {
    emit(state.copyWith(connectionStatus: event.status));
  }

  void _onDisconnect(DisconnectEvent event, Emitter<BookingSeatState> emit) {
    _repository.disconnect();
    _seatUpdatesSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    
    emit(state.copyWith(
      connectionStatus: 'disconnected',
      currentShowingId: null,
      selectedSeats: [],
      seatStatusUpdates: {},
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
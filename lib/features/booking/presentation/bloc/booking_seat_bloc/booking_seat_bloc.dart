import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/booking/data/repositories/booking_seat_repository_impl.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_seat_repository.dart';

import '../../../data/models/models.dart';
import '../bloc.dart';

class BookingSeatBloc extends Bloc<BookingSeatEvent, BookingSeatState> {
  final BookingSeatRepositoryImpl bookingSeatRepository;
  final List<StreamSubscription> _subscriptions = [];

  BookingSeatBloc({required this.bookingSeatRepository}) : super(BookingSeatInitial()) {
    on<BookingLoadSeats>(_onLoadSeats);
    on<BookingSeatUpdated>(_onSeatUpdated);
    on<BulkSeatsUpdated>(_onBulkSeatsUpdated);
    on<ReserveSeat>(_onReserveSeat);
    on<ConfirmSeatReservation>(_onConfirmSeatReservation);
    on<CancelSeatReservation>(_onCancelSeatReservation);
    on<ConnectionStateChanged>(_onConnectionStateChanged);
  }

  Future<void> _onLoadSeats(BookingLoadSeats event, Emitter<BookingSeatState> emit) async {
    emit(BookingSeatLoading());
    try {
      await bookingSeatRepository.connect();
      
      _subscriptions.add(
        bookingSeatRepository.onConnectionStateChange.listen((state) {
          add(ConnectionStateChanged(state));
        })
      );
      
      _subscriptions.add(
        bookingSeatRepository.onSeatUpdate.listen((seat) {
          if (seat.showingId == event.showingId) {
            add(BookingSeatUpdated(seat));
          }
        })
      );
      
      _subscriptions.add(
        bookingSeatRepository.onBulkSeatUpdate.listen((seats) {
          if (seats.isNotEmpty && seats.first.showingId == event.showingId) {
            add(BulkSeatsUpdated(seats));
          }
        })
      );
      
      await bookingSeatRepository.joinShowing(event.showingId);
      final seats = await bookingSeatRepository.loadInitialSeats(event.showingId);
      
      emit(BookingSeatLoaded(seats: seats));
    } catch (e) {
      emit(BookingSeatOperationFailure('Không thể tải thông tin ghế: $e'));
    }
  }

  void _onSeatUpdated(BookingSeatUpdated event, Emitter<BookingSeatState> emit) {
    if (state is BookingSeatLoaded) {
      final currentState = state as BookingSeatLoaded;
      final updatedSeats = List<Seat>.from(currentState.seats);

      final index = updatedSeats.indexWhere((s) => s.seatId == event.seat.seatId);
      if (index != -1) {
        updatedSeats[index] = event.seat;
      } else {
        updatedSeats.add(event.seat);
      }
      
      emit(currentState.copyWith(seats: updatedSeats));
    }
  }

  void _onBulkSeatsUpdated(BulkSeatsUpdated event, Emitter<BookingSeatState> emit) {
    if (state is BookingSeatLoaded) {
      final currentState = state as BookingSeatLoaded;
      emit(currentState.copyWith(seats: event.seats));
    }
  }

  Future<void> _onReserveSeat(ReserveSeat event, Emitter<BookingSeatState> emit) async {
    final currentState = state;
    if (currentState is BookingSeatLoaded) {
      emit(BookingSeatOperationInProgress());
      try {
        final result = await bookingSeatRepository.reserveSeat(
          event.showingId,
          event.seatId,
          event.userId,
        );
        emit(BookingSeatOperationFailure('Đặt ghế thành công: $result'));
        emit(currentState); // Quay lại trạng thái trước đó, cập nhật ghế sẽ qua stream
      } catch (e) {
        emit(BookingSeatOperationFailure('Đặt ghế thất bại: $e'));
        emit(currentState);
      }
    }
  }

  Future<void> _onConfirmSeatReservation(ConfirmSeatReservation event, Emitter<BookingSeatState> emit) async {
    final currentState = state;
    if (currentState is BookingSeatLoaded) {
      emit(BookingSeatOperationInProgress());
      try {
        final result = await bookingSeatRepository.confirmSeatReservation(
          event.showingId,
          event.seatId,
          event.userId,
        );
        emit(BookingSeatOperationSuccess('Xác nhận đặt ghế thành công: $result'));
        emit(currentState); // Quay lại trạng thái trước đó, cập nhật ghế sẽ qua stream
      } catch (e) {
        emit(BookingSeatOperationFailure('Xác nhận đặt ghế thất bại: $e'));
        emit(currentState);
      }
    }
  }

  Future<void> _onCancelSeatReservation(CancelSeatReservation event, Emitter<BookingSeatState> emit) async {
    final currentState = state;
    if (currentState is BookingSeatLoaded) {
      emit(BookingSeatOperationInProgress());
      try {
        final result = await bookingSeatRepository.cancelSeatReservation(
          event.showingId,
          event.seatId,
          event.userId,
        );
        emit(BookingSeatOperationSuccess('Hủy đặt ghế thành công: $result'));
        emit(currentState); // Quay lại trạng thái trước đó, cập nhật ghế sẽ qua stream
      } catch (e) {
        emit(BookingSeatOperationFailure('Hủy đặt ghế thất bại: $e'));
        emit(currentState);
      }
    }
  }

  void _onConnectionStateChanged(ConnectionStateChanged event, Emitter<BookingSeatState> emit) {
    if (state is BookingSeatLoaded) {
      final currentState = state as BookingSeatLoaded;
      emit(currentState.copyWith(connectionState: event.connectionState));
    }
  }

  @override
  Future<void> close() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
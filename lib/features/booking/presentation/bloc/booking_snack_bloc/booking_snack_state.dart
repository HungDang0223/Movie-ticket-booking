import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/booking/data/models/snack.dart';

class BookingSnackState extends Equatable {
  BookingSnackState();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class BookingSnackInitial extends BookingSnackState {}

class BookingSnackLoading extends BookingSnackState {}

class BookingSnackLoadedSuccess extends BookingSnackState {
  final List<Snack> snacks;
  BookingSnackLoadedSuccess(this.snacks);

  @override
  // TODO: implement props
  List<Object?> get props => [snacks];
}

class BookingSnackLoadedFailed extends BookingSnackState {
  final String message;
  BookingSnackLoadedFailed(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => [message];
}
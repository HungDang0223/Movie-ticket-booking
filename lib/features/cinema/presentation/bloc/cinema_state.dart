import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/cinema/data/models/cinema.dart';

class CinemaState extends Equatable {
  const CinemaState();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CinemaInitial extends CinemaState {}
class CinemaLoading extends CinemaState {}
class CinemaLoadedSuccess extends CinemaState {
  final dynamic cinemas; // Replace with your actual cinema model

  const CinemaLoadedSuccess(this.cinemas);

  @override
  List<Object?> get props => [cinemas];
}
class CinemaLoadedFailure extends CinemaState {
  final String message;

  const CinemaLoadedFailure(this.message);

  @override
  List<Object?> get props => [message];
}
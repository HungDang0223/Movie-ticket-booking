import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';

class ShowingMovieState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShowingMovieInitial extends ShowingMovieState {}
class ShowingMovieLoading extends ShowingMovieState {}
class ShowingMovieLoaded extends ShowingMovieState {
  final List<ShowingMovieResponse> showingMovies;

  ShowingMovieLoaded({required this.showingMovies});

  @override
  List<Object?> get props => [showingMovies];
}
class ShowingMovieError extends ShowingMovieState {
  final String message;

  ShowingMovieError({required this.message});

  @override
  List<Object?> get props => [message];
}
import 'package:equatable/equatable.dart';

class ShowingMovieEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetShowingMovieEvent extends ShowingMovieEvent {
  final int movieId;
  final DateTime date;

  GetShowingMovieEvent({required this.movieId, required this.date});

  @override
  List<Object?> get props => [movieId, date];
}

class GetShowingMovieByCinemaIdEvent extends ShowingMovieEvent {
  final int cinemaId;
  final DateTime date;

  GetShowingMovieByCinemaIdEvent({required this.cinemaId, required this.date});

  @override
  List<Object?> get props => [cinemaId, date];
}
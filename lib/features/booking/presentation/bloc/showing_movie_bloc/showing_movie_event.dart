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
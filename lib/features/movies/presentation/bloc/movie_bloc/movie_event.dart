import 'package:equatable/equatable.dart';

class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class GetListShowingMoviesEvent extends MovieEvent {
  const GetListShowingMoviesEvent();

  @override
  List<Object?> get props => [];
}

class GetMovieDetailEvent extends MovieEvent {
  final int id;

  const GetMovieDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}
import 'package:equatable/equatable.dart';

class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class GetListShowingMoviesEvent extends MovieEvent {
  const GetListShowingMoviesEvent();
}

class GetListUpcomingMoviesEvent extends MovieEvent {
  const GetListUpcomingMoviesEvent();
}

class GetMovieDetailEvent extends MovieEvent {
  final int id;

  const GetMovieDetailEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshShowingMoviesEvent extends MovieEvent {
  const RefreshShowingMoviesEvent();
}

class RefreshUpcomingMoviesEvent extends MovieEvent {
  const RefreshUpcomingMoviesEvent();
}
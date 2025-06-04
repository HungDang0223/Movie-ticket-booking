import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

class MovieState {
  const MovieState();
}

class MovieInitial extends MovieState {
  const MovieInitial();
}

class MovieLoading extends MovieState {
  const MovieLoading();
}

class MovieLoadedSuccess extends MovieState {
  final List<MovieModel> movies;
  const MovieLoadedSuccess(this.movies);
}

class MovieLoadedFailed extends MovieState {
  final String errorMessage;
  const MovieLoadedFailed(this.errorMessage);
}

class GetMovieDetailSuccess extends MovieState{
  final MovieModel movie;
  const GetMovieDetailSuccess(this.movie);
}
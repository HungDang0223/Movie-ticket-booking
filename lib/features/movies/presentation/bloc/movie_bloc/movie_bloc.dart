import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/features/movies/domain/usecases/get_list_movie_uc.dart';

import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;

  MovieBloc({
    required this.movieRepository
  }) : super(const MovieInitial()) {
    on<GetListShowingMoviesEvent>(_getListMovies);
    on<GetMovieDetailEvent>(_getMovieDetail);
  }

  Future<void> _getListMovies(
      GetListShowingMoviesEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    final getListMoviesUseCase = GetListMoviesUseCase(movieRepository);
    final result = await getListMoviesUseCase.call(0);
  
    if (result.isSuccess) {
      final movies = result.data;
      if (movies == null) {
        emit(const MovieLoadedFailed("Get list movies got null error"));
      }
      else {
        emit(MovieLoaded(movies));
      }
    } else {
      emit(MovieLoadedFailed("Get movies failed: ${result.failure!.message}"));
    }
  }

  Future<void> _getMovieDetail(GetMovieDetailEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    final getListMoviesUseCase = GetListMoviesUseCase(movieRepository);
    final result = await getListMoviesUseCase.call(event.id);
  
    if (result.isSuccess) {
      final movie = result.data;
      if (movie == null) {
        emit(const MovieLoadedFailed("Get movies details got null error"));
      }
      else {
        emit(MovieLoaded(movie));
      }
    } else {
      emit(MovieLoadedFailed("Get movie detail failed: ${result.failure!.message}"));
    }
  }
}
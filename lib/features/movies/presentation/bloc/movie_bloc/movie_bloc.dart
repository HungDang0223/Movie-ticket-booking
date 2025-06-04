import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/features/movies/domain/usecases/get_movie_detail_uc.dart';

import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;

  MovieBloc({
    required this.movieRepository
  }) : super(const MovieInitial()) {
    on<GetListShowingMoviesEvent>(_getShowingMovies);
    on<GetListUpcomingMoviesEvent>(_getUpcomingMovies);
    on<GetMovieDetailEvent>(_getMovieDetail);
    on<RefreshShowingMoviesEvent>(_refreshShowingMovies);
    on<RefreshUpcomingMoviesEvent>(_refreshUpcomingMovies);
  }

  Future<void> _getShowingMovies(
      GetListShowingMoviesEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    
    final result = await movieRepository.getListShowingMovies();
  
    if (result.isSuccess) {
      final movies = result.data;
      if (movies == null) {
        emit(const MovieLoadedFailed("Get showing movies got null error"));
      } else {
        emit(MovieLoadedSuccess(movies));
      }
    } else {
      emit(MovieLoadedFailed("Get showing movies failed: ${result.failure!.message}"));
    }
  }

  Future<void> _getUpcomingMovies(
      GetListUpcomingMoviesEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    
    
    final result = await movieRepository.getListUpcomingMovies();
  
    if (result.isSuccess) {
      final movies = result.data;
      if (movies == null) {
        emit(const MovieLoadedFailed("Get upcoming movies got null error"));
      } else {
        emit(MovieLoadedSuccess(movies));
      }
    } else {
      emit(MovieLoadedFailed("Get upcoming movies failed: ${result.failure!.message}"));
    }
  }

  Future<void> _getMovieDetail(GetMovieDetailEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    
    final getMovieDetailUseCase = GetMovieDetailUseCase(movieRepository);
    final result = await getMovieDetailUseCase.call(event.id);
  
    if (result.isSuccess) {
      final movie = result.data;
      if (movie == null) {
        emit(const MovieLoadedFailed("Get movie details got null error"));
      } else {
        emit(GetMovieDetailSuccess(movie));
      }
    } else {
      emit(MovieLoadedFailed("Get movie detail failed: ${result.failure!.message}"));
    }
  }

  Future<void> _refreshShowingMovies(
      RefreshShowingMoviesEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    
    // Assuming you have refresh methods in repository
    final result = await (movieRepository as dynamic).refreshShowingMovies();
  
    if (result.isSuccess) {
      final movies = result.data;
      if (movies == null) {
        emit(const MovieLoadedFailed("Refresh showing movies got null error"));
      } else {
        emit(MovieLoadedSuccess(movies));
      }
    } else {
      emit(MovieLoadedFailed("Refresh showing movies failed: ${result.failure!.message}"));
    }
  }

  Future<void> _refreshUpcomingMovies(
      RefreshUpcomingMoviesEvent event, Emitter<MovieState> emit) async {
    emit(const MovieLoading());
    
    // Assuming you have refresh methods in repository
    final result = await (movieRepository as dynamic).refreshUpcomingMovies();
  
    if (result.isSuccess) {
      final movies = result.data;
      if (movies == null) {
        emit(const MovieLoadedFailed("Refresh upcoming movies got null error"));
      } else {
        emit(MovieLoadedSuccess(movies));
      }
    } else {
      emit(MovieLoadedFailed("Refresh upcoming movies failed: ${result.failure!.message}"));
    }
  }
}
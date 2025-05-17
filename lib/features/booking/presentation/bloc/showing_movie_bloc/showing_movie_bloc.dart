import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:movie_tickets/features/booking/domain/repositories/showing_movie_repository.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/showing_movie_bloc/showing_movie_event.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/showing_movie_bloc/showing_movie_state.dart';

class ShowingMovieBloc extends Bloc<ShowingMovieEvent, ShowingMovieState> {
  final ShowingMovieRepository repository;
  ShowingMovieBloc({required this.repository}) : super(ShowingMovieInitial()) {
    on<GetShowingMovieEvent>((event, emit) async {
      emit(ShowingMovieLoading());
      try {
        final result = await repository.getShowingMovies(event.movieId, event.date);
        if (result.isSuccess) {
          if (result.data != null) {
            log('${result.data![0].cinemaName}', name: 'Get showings movies UC');
            emit(ShowingMovieLoaded(showingMovies: result.data!));
          } else {
            emit(ShowingMovieError(message: "Get showings movie NULL"));
          }
          
        } else {
          emit(ShowingMovieError(message: result.failure!.message));
        }
      } catch (e) {
        emit(ShowingMovieError(message: e.toString()));
      }
    });
  }
}
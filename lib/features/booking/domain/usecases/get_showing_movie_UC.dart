import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';

import '../repositories/showing_movie_repository.dart';

class GetShowingMovieUc implements UseCase<List<ShowingMovieResponse>, GetShowingMovieParams> {
  final ShowingMovieRepository repository;

  GetShowingMovieUc(this.repository);

  @override
  Future<Result<List<ShowingMovieResponse>>> call(GetShowingMovieParams params) async {
    return await repository.getShowingMovies(params.cinemaId, params.date);
  }
}

class GetShowingMovieParams {
  final int cinemaId;
  final DateTime date;

  GetShowingMovieParams({required this.cinemaId, required this.date});
}
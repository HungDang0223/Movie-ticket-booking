import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';


abstract class ShowingMovieRepository {
  Future<Result<List<ShowingMovieResponse>>> getShowingMoviesByMovieId(int movieId, DateTime date);
  Future<Result<List<ShowingMovieResponse>>> getShowingMoviesByCinemaId(int cinemaId, DateTime date);
}
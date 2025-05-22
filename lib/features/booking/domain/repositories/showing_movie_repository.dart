import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';


abstract class ShowingMovieRepository {
  Future<Result<List<ShowingMovieResponse>>> getShowingMovies(int movieId, DateTime date);
}
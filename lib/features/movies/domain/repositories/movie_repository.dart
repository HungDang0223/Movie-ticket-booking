import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

abstract class MovieRepository {
  Future<Result<List<MovieModel>>> getAllMovies();
  Future<Result<List<MovieModel>>> getListShowingMovies();
  Future<Result<List<MovieModel>>> getListUpcomingMovies();
  Future<Result<MovieModel>> getMovieDetail(int id);
}
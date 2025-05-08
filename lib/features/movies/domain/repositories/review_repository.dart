import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';

abstract class ReviewRepository {
  Future<Result<List<ReviewModel>>> getMovieReivews(int movieId);
}
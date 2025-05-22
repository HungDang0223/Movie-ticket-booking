import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';

abstract class ReviewRepository {
  Future<Result<List<MovieReview>>> getMovieReivews(int movieId, int page, int limit, String? sort);
  Future<Result<MovieReview>> postMovieReview(int movieId, Map<String, dynamic> reviewData);
  Future<Result<MovieReview>> updateMovieReview(int reviewId, Map<String, dynamic> reviewData);
  Future<Result<bool>> deleteMovieReview(int reviewId);
  Future<Result<bool>> likeMovieReview(int reviewId);
  Future<Result<bool>> unlikeMovieReview(int reviewId);
}
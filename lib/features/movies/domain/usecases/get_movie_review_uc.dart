import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';

class GetMovieReviewsUseCase implements UseCase<List<MovieReview>, GetMovieReviewsUseCaseParams> {
  final ReviewRepository reviewRepository;

  const GetMovieReviewsUseCase(this.reviewRepository);

  @override
  Future<Result<List<MovieReview>>> call(GetMovieReviewsUseCaseParams params) async {
    return await reviewRepository.getMovieReivews(params.movieId, params.page, params.limit, params.sort);
  }

}

class GetMovieReviewsUseCaseParams {
  final int movieId;
  final int page;
  final int limit;
  final String? sort;

  const GetMovieReviewsUseCaseParams({
    required this.movieId,
    required this.page,
    required this.limit,
    this.sort,
  });
}
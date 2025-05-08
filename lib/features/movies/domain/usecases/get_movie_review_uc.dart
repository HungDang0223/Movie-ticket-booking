import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';

class GetMovieReviewUseCase implements UseCase<List<ReviewModel>, int> {
  final ReviewRepository reviewRepository;

  const GetMovieReviewUseCase(this.reviewRepository);

  @override
  Future<Result<List<ReviewModel>>> call(int movieId) async {
    return await reviewRepository.getMovieReivews(movieId);
  }

}
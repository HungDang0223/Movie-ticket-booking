import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';

class GetMovieDetailUseCase implements UseCase<MovieModel, int> {
  final MovieRepository movieRepository;

  GetMovieDetailUseCase(this.movieRepository);
  @override
  Future<Result<MovieModel>> call(int params) async {
    return await movieRepository.getMovieDetail(params);
  }

}
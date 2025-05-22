import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';

class GetListMoviesUseCase implements UseCase<List<MovieModel>, int> {
  final MovieRepository movieRepository;

  GetListMoviesUseCase(this.movieRepository);

  @override
  Future<Result<List<MovieModel>>> call(int params) async {
    return await movieRepository.getListShowingMovies();
  }
}
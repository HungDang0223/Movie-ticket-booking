import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'review_remote_datasource.g.dart';

@RestApi(baseUrl: '$baseURL/review')
abstract class ReviewRemoteDatasource {
  factory ReviewRemoteDatasource(Dio dio) = _ReviewRemoteDatasource;

  @GET('/{movieId}')
  Future<HttpResponse<List<MovieReview>>> getMovieModels(
    @Path("movieId") int movieId,
  );

}
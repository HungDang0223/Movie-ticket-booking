import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:retrofit/retrofit.dart';

part 'review_remote_datasource.g.dart';

@RestApi(baseUrl: '$baseURL/review')
abstract class ReviewRemoteDatasource {
  factory ReviewRemoteDatasource(Dio dio) = _ReviewRemoteDatasource;

  @GET('/{movieId}')
  Future<HttpResponse<ReviewResponse>> getMovieModels(
    @Path("movieId") int movieId,
      @Query("page") int page,
      @Query("limit") int limit,
      @Query("sort") String? sort,
  );

  @POST('/{movieId}')
  Future<HttpResponse<MovieReview>> postMovieReview(
    @Path("movieId") int movieId,
    @Body() Map<String, dynamic> reviewData,
  );

  @PATCH('/{reviewId}')
  Future<HttpResponse<MovieReview>> updateMovieReview(
    @Path("reviewId") int reviewId,
    @Body() Map<String, dynamic> reviewData,
  );

  @DELETE('/{reviewId}')
  Future<HttpResponse<RegularResponse>> deleteMovieReview(
    @Path("reviewId") int reviewId,
  );

  @PATCH('/{reviewId}/like')
  Future<HttpResponse<RegularResponse>> likeMovieReview(
    @Path("reviewId") int reviewId,
  );

  @PATCH('/{reviewId}/unlike')
  Future<HttpResponse<RegularResponse>> unlikeMovieReview(
    @Path("reviewId") int reviewId,
  );

}
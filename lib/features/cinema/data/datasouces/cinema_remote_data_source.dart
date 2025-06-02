import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/cinema/data/models/cinema.dart';
import 'package:retrofit/retrofit.dart';

part 'cinema_remote_data_source.g.dart';

@RestApi(baseUrl: baseURL)
abstract class CinemaRemoteDataSource {
  factory CinemaRemoteDataSource(Dio dio, {String baseUrl}) = _CinemaRemoteDataSource;

  @GET('/cinema')
  Future<HttpResponse<CinemaResponse>> getCinemas();

  @GET('/cinema/city/{cityId}')
  Future<HttpResponse<List<Cinema>>> getCinemasByCityId(@Path('cityId') int cityId);

  @GET('cinema/city')
  Future<HttpResponse<List<Cinema>>> getCinemasByCityName(@Query('name') String cityName);
}
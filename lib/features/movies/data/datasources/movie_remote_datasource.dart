import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/my_const.dart';

part 'movie_remote_datasource.g.dart';

@RestApi(baseUrl: "$baseURL/movie")
abstract class MovieRemoteDatasource {
  factory MovieRemoteDatasource(Dio dio) = _MovieRemoteDatasource;
  
  @GET("")
  Future<HttpResponse<List<MovieModel>>> getListMovies(
    // @Query("stauts") String? status, // upcoming, showing, ended
  );
  
  @GET("/{id}")
  Future<HttpResponse<MovieModel>> getMovieById(
    @Path("id") int id,
  );
}
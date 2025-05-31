import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/booking/data/models/models.dart';
import 'package:retrofit/retrofit.dart';

part 'showing_movie_remote_data_source.g.dart';

@RestApi(baseUrl: showingMovieAPIBaseURL)
abstract class ShowingMovieRemoteDataSource {
  factory ShowingMovieRemoteDataSource(Dio dio) = _ShowingMovieRemoteDataSource;

  // /movie/{movieId}?date={date}
  // /cinema/{cinemaId}?date={date}
  @GET('/movie/{movieId}')
  Future<HttpResponse<List<ShowingMovieResponse>>> getShowingMoviesByMovieId(
    @Path('movieId') int movieId,
    @Query('date') DateTime data
  );
  
  @GET('/cinema/{cinemaId}')
  Future<HttpResponse<List<ShowingMovieResponse>>> getShowingMoviesByCinemaId(
    @Path('cinemaId') int cinemaId,
    @Query('date') DateTime data
  );
}
//**
// {
//   Name: tên rạp hoặc tên phim
//   Showing: [
//     {
//       "showingId": 35,
//       "screenId": 1,
//       "startTime": "09:00:00",
//       "endTime": "10:45:00",
//       "showingDate": "2025-05-13T00:00:00",
//       "showingFormat": "2D",
//       "cinemaName": "TC Vincom Bà Triệu",
//       "screenName": "Screen 1",
//       "seatCount": 112
//     },
//     {
//       "showingId": 36,
//       "screenId": 1,
//       "startTime": "11:10:00",
//       "endTime": "12:55:00",
//       "showingDate": "2025-05-13T00:00:00",
//       "showingFormat": "2D",
//       "cinemaName": "TC Vincom Bà Triệu",
//       "screenName": "Screen 1",
//       "seatCount": 112
//     },
//   ]
// }
// Model class for the response from the showing movie API.
class ShowingMovieResponse {
  final String name; // cinema name or movie name
  final List<ShowingMovie> showingMovies;
  const ShowingMovieResponse({
    required this.name,
    required this.showingMovies,
  });
  factory ShowingMovieResponse.fromJson(Map<String, dynamic> json) {
    final name = json['Name'] as String;
    final showingMovies = (json['Showings'] as List)
        .map((e) => ShowingMovie.fromJson(e))
        .toList();
    return ShowingMovieResponse(
      name: name,
      showingMovies: showingMovies,
    );
  }
  @override
  String toString() {
    // TODO: implement toString
    return "Cinema name: $name, showings: ${showingMovies.length}";
  }
}
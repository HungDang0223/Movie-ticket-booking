import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/booking/data/models/models.dart';
import 'package:retrofit/retrofit.dart';

part 'showing_movie_remote_data_source.g.dart';

@RestApi(baseUrl: showingMovieAPIBaseURL)
abstract class ShowingMovieRemoteDataSource {
  factory ShowingMovieRemoteDataSource(Dio dio) = _ShowingMovieRemoteDataSource;

  @GET('')
  Future<HttpResponse<List<ShowingMovieResponse>>> getShowingMovies(
    @Query('movie') int movieId,
    @Query('date') DateTime data
  );
  
}
//**
// {
//   CinemaName: "TC Vincom Bà Triệu"
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
  final String cinemaName;
  final List<ShowingMovie> showingMovies;
  const ShowingMovieResponse({
    required this.cinemaName,
    required this.showingMovies,
  });
  factory ShowingMovieResponse.fromJson(Map<String, dynamic> json) {
    final cinemaName = json['CinemaName'] as String;
    final showingMovies = (json['Showings'] as List)
        .map((e) => ShowingMovie.fromJson(e))
        .toList();
    return ShowingMovieResponse(
      cinemaName: cinemaName,
      showingMovies: showingMovies,
    );
  }
  @override
  String toString() {
    // TODO: implement toString
    return "Cinema name: $cinemaName, showings: ${showingMovies.length}";
  }
}
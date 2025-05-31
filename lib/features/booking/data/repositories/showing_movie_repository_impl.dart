import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';
import 'package:movie_tickets/features/booking/domain/repositories/showing_movie_repository.dart';
import 'package:movie_tickets/injection.dart';


class ShowingMovieRepositoryImpl extends ShowingMovieRepository {

  final ShowingMovieRemoteDataSource remoteDataSource;
  ShowingMovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<ShowingMovieResponse>>> getShowingMoviesByMovieId(int movieId, DateTime date) async {
    try {
      final httpResponse = await remoteDataSource.getShowingMoviesByMovieId(movieId, date);
      if (httpResponse.response.statusCode == 200) {
        final response = httpResponse.data;
        print(response);
        return Result.success(response);
      } 
      else {
        // Handle 400 errors
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "Invalid request data";
        return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Result.fromFailure(DioExceptionFailure("${e.response!.data['message']}"));
      }
      return Result.fromFailure(DioExceptionFailure("DioException: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  @override
  Future<Result<List<ShowingMovieResponse>>> getShowingMoviesByCinemaId(int cinemaId, DateTime date) async {
    try {
      final httpResponse = await remoteDataSource.getShowingMoviesByCinemaId(cinemaId, date);
      if (httpResponse.response.statusCode == 200) {
        final response = httpResponse.data;
        print(response);
        return Result.success(response);
      } 
      else {
        // Handle 400 errors
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "Invalid request data";
        return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Result.fromFailure(DioExceptionFailure("${e.response!.data['message']}"));
      }
      return Result.fromFailure(DioExceptionFailure("DioException: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }
}
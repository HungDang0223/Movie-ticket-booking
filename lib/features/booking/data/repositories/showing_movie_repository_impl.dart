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
  Future<Result<List<ShowingMovieResponse>>> getShowingMovies(int cinemaId, DateTime date) async {
    try {
      final httpResponse = await remoteDataSource.getShowingMovies(cinemaId, date);
      if (httpResponse.response.statusCode == 200) {
        final response = httpResponse.data;
        print(response);
        return Result.success(response);
      } 
      else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
        // Handle 400 errors
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "Invalid request data";
        return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
      } else if (httpResponse.response.statusCode == HttpStatus.notFound) {
        // 404 error
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "No data found";
        return Result.fromFailure(ServerFailure("$errorMessage"));
      }
      else {
        return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error"));
      }
    } on ServerException catch (e) {
      return Result.fromFailure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.fromFailure(NetworkFailure(e.message));
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
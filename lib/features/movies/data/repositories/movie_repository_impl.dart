import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/injection.dart';

class MovieRepositoryImpl extends MovieRepository {
  
  final MovieRemoteDatasource _movieRemoteDatasource = MovieRemoteDatasource(sl<Dio>());

  @override
  Future<Result<List<MovieModel>>> getListShowingMovies() async {
    try {
      final httpResponse = await _movieRemoteDatasource.getListShowingMovies();
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Response: ${httpResponse.data[0]}", name: "Get list movies UC");
        return Result.success(response);
      } 
      else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
        // Handle 400 errors
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "Bad request";
        return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
      }
      else {
        return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error"));
      }
      
    } on ServerException catch (e) {
      return Result.fromFailure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.fromFailure(NetworkFailure(e.message));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
            print("Connection timed out: ${e.message}");
        return Result.fromFailure(NetworkFailure("Connection timed out. Please try again later."));
      }
      return Result.fromFailure(ServerFailure("DioException: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }
  
  @override
  Future<Result<MovieModel>> getMovieDetail(int id) async {
    try {
      final httpResponse = await _movieRemoteDatasource.getMovieById(id);
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Response: ${httpResponse.data}", name: "Get list movies UC");
        return Result.success(response);
      } 
      else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
        // Handle 400 errors
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "Bad request";
        return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
      }
      else {
        return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error"));
      }
      
    } on ServerException catch (e) {
      return Result.fromFailure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.fromFailure(NetworkFailure(e.message));
    } on DioException catch (e) {
      return Result.fromFailure(ServerFailure("DioException: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

}

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/datasources/review_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:movie_tickets/features/movies/domain/entities/review.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';
import 'package:movie_tickets/injection.dart';

class ReviewRepositoryImpl extends ReviewRepository {

  final ReviewRemoteDatasource _reviewRemoteDatasource = sl<ReviewRemoteDatasource>();
  
  @override
  Future<Result<List<MovieReview>>> getMovieReivews(int movieId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.getMovieModels(movieId);
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Response: ${httpResponse.data}", name: "Get movie reviews UC");
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
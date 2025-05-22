import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/datasources/review_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';
import 'package:movie_tickets/injection.dart';

class ReviewRepositoryImpl extends ReviewRepository {

  final ReviewRemoteDatasource _reviewRemoteDatasource = sl<ReviewRemoteDatasource>();
  
  @override
  Future<Result<List<MovieReview>>> getMovieReivews(int movieId, int page, int limit, String? sort) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.getMovieModels(movieId, page, limit, sort);
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Response: ${httpResponse.data}", name: "Get movie reviews UC");
        if (response.reviews == null) {
          return Result.fromFailure(ServerFailure("No reviews found"));
        }
        if (response.reviews == null || response.reviews!.isEmpty) {
          return Result.fromFailure(ServerFailure("No reviews found"));
        }
        return Result.success(response.reviews!);
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

  @override
  Future<Result<bool>> deleteMovieReview(int reviewId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.deleteMovieReview(reviewId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return Result.success(true);
      } else {
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

  @override
  Future<Result<bool>> likeMovieReview(int reviewId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.likeMovieReview(reviewId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return Result.success(true);
      } else {
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

  @override
  Future<Result<MovieReview>> postMovieReview(int movieId, Map<String, dynamic> reviewData) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.postMovieReview(movieId, reviewData);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final data = httpResponse.data as Map<String, dynamic>;
        final response = MovieReview.fromJson(data);
        log("Response: ${httpResponse.data}", name: "Post movie review UC");
        return Result.success(response);
      } else {
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

  @override
  Future<Result<bool>> unlikeMovieReview(int reviewId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.unlikeMovieReview(reviewId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return Result.success(true);
      } else {
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

  @override
  Future<Result<MovieReview>> updateMovieReview(int reviewId, Map<String, dynamic> reviewData) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.updateMovieReview(reviewId, reviewData);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final data = httpResponse.data as Map<String, dynamic>;
        final response = MovieReview.fromJson(data);
        log("Response: ${httpResponse.data}", name: "Update movie review UC");
        return Result.success(response);
      } else {
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
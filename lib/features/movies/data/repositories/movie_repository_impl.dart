// import 'dart:developer';
// import 'dart:io';
// import 'dart:async';

// import 'package:dio/dio.dart';
// import 'package:movie_tickets/core/errors/exceptions.dart';
// import 'package:movie_tickets/core/errors/failures.dart';
// import 'package:movie_tickets/core/utils/result.dart';
// import 'package:movie_tickets/features/movies/data/datasources/movie_remote_datasource.dart';
// import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
// import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
// import 'package:movie_tickets/injection.dart';

// class MovieRepositoryImpl extends MovieRepository {
  
//   final MovieRemoteDatasource _movieRemoteDatasource = MovieRemoteDatasource(sl<Dio>());

//   @override
//   Future<Result<List<MovieModel>>> getListShowingMovies() async {
//     try {
//       final httpResponse = await _movieRemoteDatasource.getListShowingMovies();
      
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         final response = httpResponse.data;
//         log("Response: ${httpResponse.data[0]}", name: "Get list movies UC");
//         return Result.success(response);
//       } 
//       else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
//         // Handle 400 errors
//         final responseBody = httpResponse.response.data;
//         final errorMessage = responseBody["message"] ?? "Bad request";
//         return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
//       }
//       else {
//         return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error"));
//       }
      
//     } on ServerException catch (e) {
//       return Result.fromFailure(ServerFailure(e.message));
//     } on NetworkException catch (e) {
//       return Result.fromFailure(NetworkFailure(e.message));
//     } on DioException catch (e) {
//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.receiveTimeout ||
//           e.type == DioExceptionType.sendTimeout) {
//             print("Connection timed out: ${e.message}");
//         return Result.fromFailure(NetworkFailure("Connection timed out. Please try again later."));
//       }
//       return Result.fromFailure(ServerFailure("DioException: ${e.message}"));
//     } catch (e) {
//       return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
//     }
//   }
  
//   @override
//   Future<Result<MovieModel>> getMovieDetail(int id) async {
//     try {
//       final httpResponse = await _movieRemoteDatasource.getMovieById(id);
      
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         final response = httpResponse.data;
//         log("Response: ${httpResponse.data}", name: "Get list movies UC");
//         return Result.success(response);
//       } 
//       else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
//         // Handle 400 errors
//         final responseBody = httpResponse.response.data;
//         final errorMessage = responseBody["message"] ?? "Bad request";
//         return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
//       }
//       else {
//         return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error"));
//       }
      
//     } on ServerException catch (e) {
//       return Result.fromFailure(ServerFailure(e.message));
//     } on NetworkException catch (e) {
//       return Result.fromFailure(NetworkFailure(e.message));
//     } on DioException catch (e) {
//       return Result.fromFailure(ServerFailure("DioException: ${e.message}"));
//     } catch (e) {
//       return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
//     }
//   }

// }

import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/services/local/cache_data_service.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/injection.dart';

class MovieRepositoryImpl extends MovieRepository with CacheMixin {
  
  final MovieRemoteDatasource _movieRemoteDatasource = MovieRemoteDatasource(sl<Dio>());

  @override
  Future<Result<List<MovieModel>>> getListShowingMovies() async {
    return await getCachedData<List<MovieModel>>(
      'showing_movies', // cache key
      const Duration(minutes: 30), // cache 30 phút - movies showing thay đổi không thường xuyên
      () => _fetchShowingMoviesFromApi(), // fetch function
      (movies) => {
        'movies': movies.map((movie) => movie.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'showing_movies',
      }, // toJson
      (json) => (json['movies'] as List)
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList(), // fromJson
    );
  }
  
  @override
  Future<Result<MovieModel>> getMovieDetail(int id) async {
    return await getCachedData<MovieModel>(
      'movie_detail_$id', // cache key với movie ID
      const Duration(hours: 24), // cache 24 giờ - movie detail ít thay đổi
      () => _fetchMovieDetailFromApi(id), // fetch function
      (movie) => {
        'movie': movie.toJson(),
        'movieId': id,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'movie_detail',
      }, // toJson
      (json) => MovieModel.fromJson(json['movie'] as Map<String, dynamic>), // fromJson
    );
  }

  // Helper methods để fetch từ API
  Future<Result<List<MovieModel>>> _fetchShowingMoviesFromApi() async {
    try {
      final httpResponse = await _movieRemoteDatasource.getListShowingMovies();
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Fetched ${response.length} showing movies from API", name: "Get list movies UC");
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
        log("Connection timed out: ${e.message}", name: "Movie Repository");
        return Result.fromFailure(NetworkFailure("Connection timed out. Please try again later."));
      }
      return Result.fromFailure(ServerFailure("DioException: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  Future<Result<MovieModel>> _fetchMovieDetailFromApi(int id) async {
    try {
      final httpResponse = await _movieRemoteDatasource.getMovieById(id);
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Fetched movie detail for ID $id from API", name: "Get movie detail UC");
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

  // Utility methods để force refresh cache
  Future<Result<List<MovieModel>>> refreshShowingMovies() async {
    return await getCachedData<List<MovieModel>>(
      'showing_movies',
      const Duration(minutes: 30),
      () => _fetchShowingMoviesFromApi(),
      (movies) => {
        'movies': movies.map((movie) => movie.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'showing_movies',
      },
      (json) => (json['movies'] as List)
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      forceRefresh: true, // Force refresh
    );
  }

  Future<Result<MovieModel>> refreshMovieDetail(int id) async {
    return await getCachedData<MovieModel>(
      'movie_detail_$id',
      const Duration(hours: 24),
      () => _fetchMovieDetailFromApi(id),
      (movie) => {
        'movie': movie.toJson(),
        'movieId': id,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'movie_detail',
      },
      (json) => MovieModel.fromJson(json['movie'] as Map<String, dynamic>),
      forceRefresh: true,
    );
  }

  // Methods để clear cache cụ thể
  Future<void> clearShowingMoviesCache() async {
    await CacheService.clearCache('showing_movies');
  }

  Future<void> clearMovieDetailCache(int id) async {
    await CacheService.clearCache('movie_detail_$id');
  }

  Future<void> clearAllMovieCache() async {
    await clearShowingMoviesCache();
    // Clear all movie detail caches would require tracking all IDs
    // Alternative: clear all cache starting with 'movie_detail_'
  }
}
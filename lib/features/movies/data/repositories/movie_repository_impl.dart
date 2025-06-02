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
    );
  }

  @override
  Future<Result<List<MovieModel>>> getListUpcomingMovies() async {
    return await getCachedData<List<MovieModel>>(
      'upcoming_movies',
      const Duration(minutes: 30),
      () => _fetchUpcomingMoviesFromApi(),
      (movies) => {
        'movies': movies.map((movie) => movie.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'upcoming_movies',
      },
      (json) => (json['movies'] as List)
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Result<List<MovieModel>>> getAllMovies() async {
    return await getCachedData<List<MovieModel>>(
      'all_movies',
      const Duration(minutes: 30),
      () => _fetchAllMoviesFromApi(),
      (movies) => {
        'movies': movies.map((movie) => movie.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'all_movies',
      },
      (json) => (json['movies'] as List)
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
  
  @override
  Future<Result<MovieModel>> getMovieDetail(int id) async {
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
    );
  }

  // Helper methods to fetch from API and filter
  Future<Result<List<MovieModel>>> _fetchAllMoviesFromApi() async {
    try {
      final httpResponse = await _movieRemoteDatasource.getListMovies();
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Fetched ${response.length} movies from API", name: "Get all movies");
        return Result.success(response);
      } 
      else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
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

  Future<Result<List<MovieModel>>> _fetchShowingMoviesFromApi() async {
    final allMoviesResult = await _fetchAllMoviesFromApi();
    
    if (allMoviesResult.isSuccess) {
      final allMovies = allMoviesResult.data!;
      final showingMovies = allMovies.where((movie) => 
        movie.showingStatus.toLowerCase() == 'showing'
      ).toList();
      
      log("Filtered ${showingMovies.length} showing movies", name: "Get showing movies");
      return Result.success(showingMovies);
    } else {
      return allMoviesResult;
    }
  }

  Future<Result<List<MovieModel>>> _fetchUpcomingMoviesFromApi() async {
    final allMoviesResult = await _fetchAllMoviesFromApi();
    
    if (allMoviesResult.isSuccess) {
      final allMovies = allMoviesResult.data!;
      final upcomingMovies = allMovies.where((movie) => 
        movie.showingStatus.toLowerCase() == 'upcoming'
      ).toList();
      
      log("Filtered ${upcomingMovies.length} upcoming movies", name: "Get upcoming movies");
      return Result.success(upcomingMovies);
    } else {
      return allMoviesResult;
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

  // Utility methods to force refresh cache
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
      forceRefresh: true,
    );
  }

  Future<Result<List<MovieModel>>> refreshUpcomingMovies() async {
    return await getCachedData<List<MovieModel>>(
      'upcoming_movies',
      const Duration(minutes: 30),
      () => _fetchUpcomingMoviesFromApi(),
      (movies) => {
        'movies': movies.map((movie) => movie.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'upcoming_movies',
      },
      (json) => (json['movies'] as List)
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      forceRefresh: true,
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

  // Methods to clear cache
  Future<void> clearShowingMoviesCache() async {
    await CacheService.clearCache('showing_movies');
  }

  Future<void> clearUpcomingMoviesCache() async {
    await CacheService.clearCache('upcoming_movies');
  }

  Future<void> clearMovieDetailCache(int id) async {
    await CacheService.clearCache('movie_detail_$id');
  }

  Future<void> clearAllMovieCache() async {
    await clearShowingMoviesCache();
    await clearUpcomingMoviesCache();
    await CacheService.clearCache('all_movies');
  }
}
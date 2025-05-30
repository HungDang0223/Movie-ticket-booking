import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/services/local/cache_data_service.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/venues/data/datasouces/cinema_remote_data_source.dart';
import 'package:movie_tickets/features/venues/data/models/cinema.dart';
import 'package:movie_tickets/features/venues/domain/repositories/cinema_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CinemaRepositoryImpl extends CinemaRepository with CacheMixin {
  final CinemaRemoteDataSource remoteDataSource;
  
  CinemaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<CinemaResponse>>> GetCinemas() async {
    return await getCachedData<List<CinemaResponse>>(
      'all_cinemas', // cache key
      const Duration(days: 7), // cache duration - cinemas ít thay đổi
      () => _fetchCinemasFromApi(), // fetch function
      (cinemas) => {
        'cinemas': cinemas.map((cinema) => cinema.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      }, // toJson
      (json) => (json['cinemas'] as List)
          .map((item) => CinemaResponse.fromJson(item as Map<String, dynamic>))
          .toList(), // fromJson
    );
  }

  @override
  Future<Result<List<Cinema>>> GetCinemasByCity(int cityId) async {
    return await getCachedData<List<Cinema>>(
      'cinemas_city_$cityId', // cache key với cityId
      const Duration(days: 1), // cache 1 ngày cho cinema theo city
      () => _fetchCinemasByCityIdFromApi(cityId), // fetch function
      (cinemas) => {
        'cinemas': cinemas.map((cinema) => cinema.toJson()).toList(),
        'cityId': cityId,
        'timestamp': DateTime.now().toIso8601String(),
      }, // toJson
      (json) => (json['cinemas'] as List)
          .map((item) => Cinema.fromJson(item as Map<String, dynamic>))
          .toList(), // fromJson
    );
  }
  
  @override
  Future<Result<List<Cinema>>> GetCinemasByCityName(String cityName) async {
    // Normalize city name để làm cache key
    final normalizedCityName = cityName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    
    return await getCachedData<List<Cinema>>(
      'cinemas_city_name_$normalizedCityName', // cache key với cityName
      const Duration(days: 1), // cache 1 ngày
      () => _fetchCinemasByCityNameFromApi(cityName), // fetch function
      (cinemas) => {
        'cinemas': cinemas.map((cinema) => cinema.toJson()).toList(),
        'cityName': cityName,
        'timestamp': DateTime.now().toIso8601String(),
      }, // toJson
      (json) => (json['cinemas'] as List)
          .map((item) => Cinema.fromJson(item as Map<String, dynamic>))
          .toList(), // fromJson
    );
  }

  // Helper methods để fetch từ API
  Future<Result<List<CinemaResponse>>> _fetchCinemasFromApi() async {
    try {
      final httpResponse = await remoteDataSource.getCinemas();
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        print('Fetched ${response.length} cinemas from API');
        return Result.success(response);
      } else {
        return Result.fromFailure(
          ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error")
        );
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

  Future<Result<List<Cinema>>> _fetchCinemasByCityIdFromApi(int cityId) async {
    try {
      final httpResponse = await remoteDataSource.getCinemasByCityId(cityId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        print('Fetched ${response.length} cinemas for city $cityId from API');
        return Result.success(response);
      } else {
        return Result.fromFailure(
          ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error")
        );
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

  Future<Result<List<Cinema>>> _fetchCinemasByCityNameFromApi(String cityName) async {
    try {
      final httpResponse = await remoteDataSource.getCinemasByCityName(cityName);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        print('Fetched ${response.length} cinemas for city "$cityName" from API');
        return Result.success(response);
      } else {
        return Result.fromFailure(
          ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error")
        );
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

  // Utility methods để force refresh cache
  Future<Result<List<CinemaResponse>>> refreshCinemas() async {
    return await getCachedData<List<CinemaResponse>>(
      'all_cinemas',
      const Duration(days: 7),
      () => _fetchCinemasFromApi(),
      (cinemas) => {
        'cinemas': cinemas.map((cinema) => cinema.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      },
      (json) => (json['cinemas'] as List)
          .map((item) => CinemaResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      forceRefresh: true, // Force refresh
    );
  }

  Future<Result<List<Cinema>>> refreshCinemasByCity(int cityId) async {
    return await getCachedData<List<Cinema>>(
      'cinemas_city_$cityId',
      const Duration(days: 1),
      () => _fetchCinemasByCityIdFromApi(cityId),
      (cinemas) => {
        'cinemas': cinemas.map((cinema) => cinema.toJson()).toList(),
        'cityId': cityId,
        'timestamp': DateTime.now().toIso8601String(),
      },
      (json) => (json['cinemas'] as List)
          .map((item) => Cinema.fromJson(item as Map<String, dynamic>))
          .toList(),
      forceRefresh: true,
    );
  }

  // Method để clear cache cụ thể
  Future<void> clearCinemaCache() async {
    await CacheService.clearCache('all_cinemas');
  }

  Future<void> clearCinemaCityCache(int cityId) async {
    await CacheService.clearCache('cinemas_city_$cityId');
  }

  Future<void> clearCinemaCityNameCache(String cityName) async {
    final normalizedCityName = cityName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    await CacheService.clearCache('cinemas_city_name_$normalizedCityName');
  }
}
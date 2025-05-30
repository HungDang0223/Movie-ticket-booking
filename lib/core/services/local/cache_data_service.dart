import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generic Cache Service
class CacheService {
  static Future<void> setCache<T>(
    String key,
    T data,
    Duration duration,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = toJson(data);
      final expiryTime = DateTime.now().add(duration);
      
      await prefs.setString('cache_$key', json.encode(jsonData));
      await prefs.setString('cache_${key}_expiry', expiryTime.toIso8601String());
    } catch (e) {
      print('Error setting cache for $key: $e');
    }
  }

  static Future<T?> getCache<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_$key');
      final expiryString = prefs.getString('cache_${key}_expiry');
      
      if (cachedData == null || expiryString == null) {
        return null;
      }

      // Kiểm tra expiry
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        await clearCache(key);
        return null;
      }

      final jsonData = json.decode(cachedData);
      return fromJson(jsonData);
    } catch (e) {
      print('Error getting cache for $key: $e');
      return null;
    }
  }

  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$key');
      await prefs.remove('cache_${key}_expiry');
    } catch (e) {
      print('Error clearing cache for $key: $e');
    }
  }

  static Future<bool> isCacheValid(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString('cache_${key}_expiry');
      
      if (expiryString == null) return false;
      
      final expiry = DateTime.parse(expiryString);
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }
}

// Option 2: Mixin approach (không cần extends)
mixin CacheMixin {
  Future<Result<T>> getCachedData<T>(
    String cacheKey,
    Duration cacheDuration,
    Future<Result<T>> Function() fetchFromApi,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedData = await CacheService.getCache<T>(cacheKey, fromJson);
        if (cachedData != null) {
          print('Returning $cacheKey from cache');
          return Result.success(cachedData);
        }
      }

      print('Fetching $cacheKey from API');
      final apiResult = await fetchFromApi();
      
      if (apiResult.isSuccess) {
        CacheService.setCache(
          cacheKey,
          apiResult.data as T,
          cacheDuration,
          toJson,
        ).catchError((error) {
          print('Failed to cache $cacheKey: $error');
        });
      }
      
      return apiResult;
    } catch (e) {
      if (!forceRefresh) {
        final cachedData = await CacheService.getCache<T>(cacheKey, fromJson);
        if (cachedData != null) {
          print('Error occurred, returning cached $cacheKey');
          return Result.success(cachedData);
        }
      }
      
      return Result.fromFailure(
        ServerFailure("Unexpected error occurred: $e")
      );
    }
  }
}
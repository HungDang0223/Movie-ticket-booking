// import 'dart:developer';
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:movie_tickets/core/errors/exceptions.dart';
// import 'package:movie_tickets/core/errors/failures.dart';
// import 'package:movie_tickets/core/utils/result.dart';
// import 'package:movie_tickets/features/movies/data/datasources/review_remote_datasource.dart';
// import 'package:movie_tickets/features/movies/data/models/review_model.dart';
// import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';
// import 'package:movie_tickets/injection.dart';

// class ReviewRepositoryImpl extends ReviewRepository {

//   final ReviewRemoteDatasource _reviewRemoteDatasource = sl<ReviewRemoteDatasource>();
  
//   @override
//   Future<Result<List<MovieReview>>> getMovieReivews(int movieId, int page, int limit, String? sort) async {
//     try {
//       final httpResponse = await _reviewRemoteDatasource.getMovieModels(movieId, page, limit, sort);
      
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         final response = httpResponse.data;
//         log("Response: ${httpResponse.data}", name: "Get movie reviews UC");
//         if (response.reviews == null) {
//           return Result.fromFailure(ServerFailure("No reviews found"));
//         }
//         if (response.reviews == null || response.reviews!.isEmpty) {
//           return Result.fromFailure(ServerFailure("No reviews found"));
//         }
//         return Result.success(response.reviews!);
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

//   @override
//   Future<Result<bool>> deleteMovieReview(int reviewId) async {
//     try {
//       final httpResponse = await _reviewRemoteDatasource.deleteMovieReview(reviewId);
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         return Result.success(true);
//       } else {
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

//   @override
//   Future<Result<bool>> likeMovieReview(int reviewId) async {
//     try {
//       final httpResponse = await _reviewRemoteDatasource.likeMovieReview(reviewId);
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         return Result.success(true);
//       } else {
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

//   @override
//   Future<Result<MovieReview>> postMovieReview(int movieId, Map<String, dynamic> reviewData) async {
//     try {
//       final httpResponse = await _reviewRemoteDatasource.postMovieReview(movieId, reviewData);
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         final data = httpResponse.data as Map<String, dynamic>;
//         final response = MovieReview.fromJson(data);
//         log("Response: ${httpResponse.data}", name: "Post movie review UC");
//         return Result.success(response);
//       } else {
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

//   @override
//   Future<Result<bool>> unlikeMovieReview(int reviewId) async {
//     try {
//       final httpResponse = await _reviewRemoteDatasource.unlikeMovieReview(reviewId);
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         return Result.success(true);
//       } else {
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

//   @override
//   Future<Result<MovieReview>> updateMovieReview(int reviewId, Map<String, dynamic> reviewData) async {
//     try {
//       final httpResponse = await _reviewRemoteDatasource.updateMovieReview(reviewId, reviewData);
//       if (httpResponse.response.statusCode == HttpStatus.ok) {
//         final data = httpResponse.data as Map<String, dynamic>;
//         final response = MovieReview.fromJson(data);
//         log("Response: ${httpResponse.data}", name: "Update movie review UC");
//         return Result.success(response);
//       } else {
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

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/services/local/cache_data_service.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/movies/data/datasources/review_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';
import 'package:movie_tickets/injection.dart';

class ReviewRepositoryImpl extends ReviewRepository with CacheMixin {

  final ReviewRemoteDatasource _reviewRemoteDatasource = sl<ReviewRemoteDatasource>();
  
  @override
  Future<Result<List<MovieReview>>> getMovieReivews(int movieId, int page, int limit, String? sort) async {
    // Cache key với movieId, page, limit, sort để phân biệt các request khác nhau
    final sortKey = sort ?? 'default';
    final cacheKey = 'movie_reviews_${movieId}_p${page}_l${limit}_s$sortKey';
    
    return await getCachedData<List<MovieReview>>(
      cacheKey, // cache key
      const Duration(minutes: 15), // cache 15 phút - reviews có thể thay đổi thường xuyên
      () => _fetchMovieReviewsFromApi(movieId, page, limit, sort), // fetch function
      (reviews) => {
        'reviews': reviews.map((review) => review.toJson()).toList(),
        'movieId': movieId,
        'page': page,
        'limit': limit,
        'sort': sort,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'movie_reviews',
      }, // toJson
      (json) => (json['reviews'] as List)
          .map((item) => MovieReview.fromJson(item as Map<String, dynamic>))
          .toList(), // fromJson
    );
  }

  @override
  Future<Result<bool>> deleteMovieReview(int reviewId) async {
    try {
      final result = await _deleteMovieReviewFromApi(reviewId);
      
      // Nếu delete thành công, clear cache related
      if (result.isSuccess) {
        await _clearReviewCaches();
      }
      
      return result;
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  @override
  Future<Result<bool>> likeMovieReview(int reviewId) async {
    try {
      final result = await _likeMovieReviewFromApi(reviewId);
      
      // Nếu like thành công, clear cache để refresh data
      if (result.isSuccess) {
        await _clearReviewCaches();
      }
      
      return result;
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  @override
  Future<Result<MovieReview>> postMovieReview(int movieId, Map<String, dynamic> reviewData) async {
    try {
      final result = await _postMovieReviewFromApi(movieId, reviewData);
      
      // Nếu post thành công, clear cache để refresh data
      if (result.isSuccess) {
        await _clearMovieReviewCache(movieId);
      }
      
      return result;
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  @override
  Future<Result<bool>> unlikeMovieReview(int reviewId) async {
    try {
      final result = await _unlikeMovieReviewFromApi(reviewId);
      
      // Nếu unlike thành công, clear cache để refresh data
      if (result.isSuccess) {
        await _clearReviewCaches();
      }
      
      return result;
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  @override
  Future<Result<MovieReview>> updateMovieReview(int reviewId, Map<String, dynamic> reviewData) async {
    try {
      final result = await _updateMovieReviewFromApi(reviewId, reviewData);
      
      // Nếu update thành công, clear cache để refresh data
      if (result.isSuccess) {
        await _clearReviewCaches();
      }
      
      return result;
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }

  // Helper methods để fetch từ API
  Future<Result<List<MovieReview>>> _fetchMovieReviewsFromApi(int movieId, int page, int limit, String? sort) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.getMovieModels(movieId, page, limit, sort);
      
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        log("Fetched ${response.reviews?.length ?? 0} reviews for movie $movieId from API", name: "Get movie reviews UC");
        
        if (response.reviews == null || response.reviews!.isEmpty) {
          return Result.fromFailure(ServerFailure("No reviews found"));
        }
        return Result.success(response.reviews!);
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

  Future<Result<bool>> _deleteMovieReviewFromApi(int reviewId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.deleteMovieReview(reviewId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        log("Deleted review $reviewId successfully", name: "Delete review UC");
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

  Future<Result<bool>> _likeMovieReviewFromApi(int reviewId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.likeMovieReview(reviewId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        log("Liked review $reviewId successfully", name: "Like review UC");
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

  Future<Result<MovieReview>> _postMovieReviewFromApi(int movieId, Map<String, dynamic> reviewData) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.postMovieReview(movieId, reviewData);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final data = httpResponse.data as Map<String, dynamic>;
        final response = MovieReview.fromJson(data);
        log("Posted review for movie $movieId successfully", name: "Post movie review UC");
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

  Future<Result<bool>> _unlikeMovieReviewFromApi(int reviewId) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.unlikeMovieReview(reviewId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        log("Unliked review $reviewId successfully", name: "Unlike review UC");
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

  Future<Result<MovieReview>> _updateMovieReviewFromApi(int reviewId, Map<String, dynamic> reviewData) async {
    try {
      final httpResponse = await _reviewRemoteDatasource.updateMovieReview(reviewId, reviewData);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final data = httpResponse.data as Map<String, dynamic>;
        final response = MovieReview.fromJson(data);
        log("Updated review $reviewId successfully", name: "Update movie review UC");
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

  // Utility methods để manage cache
  Future<void> _clearMovieReviewCache(int movieId) async {
    // Clear all cache entries for specific movie
    // Note: This is a simplified approach - in production you might want to track cache keys
    await CacheService.clearCache('movie_reviews_${movieId}_p1_l10_sdefault');
    await CacheService.clearCache('movie_reviews_${movieId}_p1_l20_sdefault');
    // Add more common cache patterns as needed
  }

  Future<void> _clearReviewCaches() async {
    // Clear common review caches - simplified approach
    // In production, you might want to implement a more sophisticated cache invalidation strategy
  }

  // Public utility methods
  Future<Result<List<MovieReview>>> refreshMovieReviews(int movieId, int page, int limit, String? sort) async {
    final sortKey = sort ?? 'default';
    final cacheKey = 'movie_reviews_${movieId}_p${page}_l${limit}_s$sortKey';
    
    return await getCachedData<List<MovieReview>>(
      cacheKey,
      const Duration(minutes: 15),
      () => _fetchMovieReviewsFromApi(movieId, page, limit, sort),
      (reviews) => {
        'reviews': reviews.map((review) => review.toJson()).toList(),
        'movieId': movieId,
        'page': page,
        'limit': limit,
        'sort': sort,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'movie_reviews',
      },
      (json) => (json['reviews'] as List)
          .map((item) => MovieReview.fromJson(item as Map<String, dynamic>))
          .toList(),
      forceRefresh: true, // Force refresh
    );
  }

  Future<void> clearMovieReviewsCache(int movieId) async {
    await _clearMovieReviewCache(movieId);
  }
}
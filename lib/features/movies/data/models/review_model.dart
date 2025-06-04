import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/movies/domain/entities/review.dart';

class MovieReview extends Review with EquatableMixin {
  MovieReview({
    required super.reviewId,
    required super.fullName,
    required super.photoPath,
    required super.movieId,
    required super.rating,
    required super.reviewContent,
    required super.reviewDate,
    required super.likes,
    required super.userId,
    required super.isCurrentUser,
    required super.isLikedByCurrentUser
  });

  factory MovieReview.fromJson(Map<String, dynamic> json) {
    return MovieReview(
      isCurrentUser: json['isCurrentUser'] ?? false,
      reviewId: json['reviewId'],
      userId: json['userId'],
      fullName: json['fullName'],
      photoPath: json['photoPath'] ?? '',
      movieId: json['movieId'],
      rating: (json['rating'] as num).toInt(),
      reviewContent: json['reviewContent'],
      reviewDate: DateTime.parse(json['reviewDate']),
      likes: json['likes'],
      isLikedByCurrentUser: json['isLiked']
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'fullName': fullName,
      'photoPath': photoPath,
      'movieId': movieId,
      'rating': rating,
      'reviewContent': reviewContent,
      'reviewDate': reviewDate.toIso8601String(),
      'likes': likes,
      'isCurrentUser': isCurrentUser
    };
  }
  
  @override
  // TODO: implement props
  List<Object?> get props => [
        reviewId,
        fullName,
        photoPath,
        movieId,
        rating,
        reviewContent,
        reviewDate,
        likes,
      ];
}

class ReviewResponse {
  final String status;
  final String message;
  final List<MovieReview>? reviews;
  const ReviewResponse({
    required this.status,
    required this.message,
    this.reviews,
  });
  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      status: json['status'],
      message: json['message'],
      reviews: (json['data'] as List<dynamic>?)
          ?.map((e) => MovieReview.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'reviews': reviews?.map((e) => e.toJson()).toList(),
    };
  }
}
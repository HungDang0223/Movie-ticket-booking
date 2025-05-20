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
    required super.unlikes,
    required super.userId,
  });

  factory MovieReview.fromJson(Map<String, dynamic> json) {
    return MovieReview(
      reviewId: json['reviewId'],
      userId: json['userId'],
      fullName: json['fullName'],
      photoPath: json['photoPath'],
      movieId: json['movieId'],
      rating: (json['rating'] as num).toInt(),
      reviewContent: json['reviewContent'],
      reviewDate: DateTime.parse(json['reviewDate']),
      likes: json['likes'],
      unlikes: json['unlikes'],
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
      'unlikes': unlikes,
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
        unlikes,
      ];
}
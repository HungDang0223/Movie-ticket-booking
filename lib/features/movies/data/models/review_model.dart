import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/movies/domain/entities/review.dart';

class ReviewModel extends Review with EquatableMixin {

  ReviewModel({
required super.userName, required super.userRank, required super.reviewContent, required super.rating, required super.reviewDate});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userName: json['userName'],
      userRank: json['userRank'],
      rating: (json['rating'] as num).toDouble(),
      reviewContent: json['reviewContent'],
      reviewDate: DateTime.parse(json['reviewDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userRank': userRank,
      'rating': rating,
      'reviewContent': reviewContent,
      'reviewDate': reviewDate.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        userName,
        userRank,
        rating,
        reviewContent,
        reviewDate,
      ];

  @override
  String toString() {
    return 'Review{name: $userName, content: $reviewContent}';
  }
}
import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovieReviews extends ReviewEvent {
  final int movieId;
  final bool loadMore;

  const LoadMovieReviews({
    required this.movieId,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [movieId, loadMore];
}

class LoadAllMovieReviews extends ReviewEvent {
  final int movieId;

  const LoadAllMovieReviews({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}

class LikeMovieReview extends ReviewEvent {
  final int reviewId;

  const LikeMovieReview({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

class UnlikeMovieReview extends ReviewEvent {
  final int reviewId;

  const UnlikeMovieReview({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

class DeleteMovieReview extends ReviewEvent {
  final int reviewId;

  const DeleteMovieReview({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

class PostMovieReview extends ReviewEvent {
  final int movieId;
  final Map<String, dynamic> reviewData;

  const PostMovieReview({
    required this.movieId,
    required this.reviewData,
  });

  @override
  List<Object?> get props => [movieId, reviewData];
}

class UpdateMovieReview extends ReviewEvent {
  final int reviewId;
  final Map<String, dynamic> reviewData;

  const UpdateMovieReview({
    required this.reviewId,
    required this.reviewData,
  });

  @override
  List<Object?> get props => [reviewId, reviewData];
}

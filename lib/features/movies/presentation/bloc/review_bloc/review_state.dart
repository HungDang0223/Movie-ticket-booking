import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewLoaded extends ReviewState {
  final List<MovieReview> reviews;
  final bool hasMoreData;
  final int currentPage;

  const ReviewLoaded({
    required this.reviews,
    required this.hasMoreData,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [reviews, hasMoreData, currentPage];

  ReviewLoaded copyWith({
    List<MovieReview>? reviews,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return ReviewLoaded(
      reviews: reviews ?? this.reviews,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewActionError extends ReviewState {
  final String message;

  const ReviewActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewActionSuccess extends ReviewState{}
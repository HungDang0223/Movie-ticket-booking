import 'package:movie_tickets/features/movies/data/models/review_model.dart';

class ReviewState {
  const ReviewState();
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  const ReviewLoaded(this.reviews);
}

class ReviewLoadedFailed extends ReviewState {
  final String errorMessage;
  const ReviewLoadedFailed(this.errorMessage);
}
import 'package:equatable/equatable.dart';

class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class GetMovieReviews extends ReviewEvent {
  final int id;

  const GetMovieReviews(this.id);

  @override
  List<Object?> get props => [id];
}
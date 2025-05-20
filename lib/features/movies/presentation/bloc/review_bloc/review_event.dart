import 'package:equatable/equatable.dart';

class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class GetMovieModels extends ReviewEvent {
  final int id;

  const GetMovieModels(this.id);

  @override
  List<Object?> get props => [id];
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';

import '../bloc.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository reviewRepository;
  ReviewBloc({required this.reviewRepository}) : super(const ReviewInitial()) {
    
  }
}
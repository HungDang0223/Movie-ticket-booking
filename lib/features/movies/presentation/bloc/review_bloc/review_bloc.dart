import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';
import 'package:movie_tickets/features/movies/domain/usecases/get_movie_review_uc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_event.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_state.dart';

import '../../../data/models/review_model.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository reviewRepository;
  static const int _pageSize = 2;

  ReviewBloc({required this.reviewRepository}) : super(const ReviewInitial()) {
    on<LoadMovieReviews>(_onLoadMovieReviews);
    on<LoadAllMovieReviews>(_onLoadAllMovieReviews);
    on<LikeMovieReview>(_onLikeMovieReview);
    on<UnlikeMovieReview>(_onUnlikeMovieReview);
    on<DeleteMovieReview>(_onDeleteMovieReview);
    on<PostMovieReview>(_onPostMovieReview);
    on<UpdateMovieReview>(_onUpdateMovieReview);
  }

  Future<void> _onLoadMovieReviews(
    LoadMovieReviews event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      if (!event.loadMore) {
        emit(const ReviewLoading());
      }

      final currentState = state;
      final currentPage = (currentState is ReviewLoaded) ? currentState.currentPage : 1;
      final existingReviews = (currentState is ReviewLoaded) ? currentState.reviews : [];

      if (event.loadMore && currentState is ReviewLoaded && !currentState.hasMoreData) {
        return;
      }

      final useCase = GetMovieReviewsUseCase(reviewRepository);
      final result = await useCase.call(
        GetMovieReviewsUseCaseParams(
          movieId: event.movieId,
          page: event.loadMore ? currentPage + 1 : 1,
          limit: _pageSize,
          sort: null,
        ),
      );

      result.when(
        success: (reviews) {
          final hasMore = reviews.length >= _pageSize;
          final newReviews = (event.loadMore ? [...existingReviews, ...reviews] : reviews) as List<MovieReview>;

          emit(ReviewLoaded(
            reviews: newReviews,
            hasMoreData: hasMore,
            currentPage: event.loadMore ? currentPage + 1 : 1,
          ));
        },
        failure: (failure) {
          if (!event.loadMore) {
            emit(ReviewError(failure.message));
          }
        },
      );
    } catch (e) {
      if (!event.loadMore) {
        emit(ReviewError(e.toString()));
      }
    }
  }

  Future<void> _onLoadAllMovieReviews(
    LoadAllMovieReviews event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(const ReviewLoading());

      List<MovieReview> allReviews = [];
      bool hasMore = true;
      int page = 1;

      while (hasMore) {
        final useCase = GetMovieReviewsUseCase(reviewRepository);
        final result = await useCase.call(
          GetMovieReviewsUseCaseParams(
            movieId: event.movieId,
            page: page,
            limit: _pageSize,
            sort: null,
          ),
        );

        result.when(
          success: (reviews) async {
            allReviews.addAll(reviews);
            hasMore = reviews.length >= _pageSize;
            page++;
          },
          failure: (failure) async {
            hasMore = false;
            if (allReviews.isEmpty) {
              emit(ReviewError(failure.message));
              return;
            }
          },
        );
      }

      emit(ReviewLoaded(
        reviews: allReviews,
        hasMoreData: false,
        currentPage: page,
      ));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onLikeMovieReview(
    LikeMovieReview event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final result = await reviewRepository.likeMovieReview(event.reviewId);
      
      result.when(
        success: (success) {
          emit(ReviewActionSuccess());
          if (success && state is ReviewLoaded) {
            final currentState = state as ReviewLoaded;
            final updatedReviews = currentState.reviews.map((review) {
              if (review.reviewId == event.reviewId) {
                // Create a new review with updated likes count
                return MovieReview(
                  reviewId: review.reviewId,
                  fullName: review.fullName,
                  photoPath: review.photoPath,
                  movieId: review.movieId,
                  rating: review.rating,
                  reviewContent: review.reviewContent,
                  reviewDate: review.reviewDate,
                  likes: review.likes + 1,
                  unlikes: review.unlikes,
                  userId: review.userId,
                );
              }
              return review;
            }).toList();

            emit(ReviewLoaded(
              reviews: updatedReviews,
              hasMoreData: currentState.hasMoreData,
              currentPage: currentState.currentPage,
            ));
          }
        },
        failure: (failure) {
          emit(ReviewActionError(failure.message));
          // Revert to previous state after showing error
          Future.delayed(const Duration(seconds: 2), () {
            if (state is ReviewActionError) {
              // You might want to reload reviews or maintain the previous state
            }
          });
        },
      );
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  Future<void> _onUnlikeMovieReview(
    UnlikeMovieReview event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final result = await reviewRepository.unlikeMovieReview(event.reviewId);
      
      result.when(
        success: (success) {
          emit(ReviewActionSuccess());
          if (success && state is ReviewLoaded) {
            final currentState = state as ReviewLoaded;
            final updatedReviews = currentState.reviews.map((review) {
              if (review.reviewId == event.reviewId) {
                // Create a new review with updated unlikes count
                return MovieReview(
                  reviewId: review.reviewId,
                  fullName: review.fullName,
                  photoPath: review.photoPath,
                  movieId: review.movieId,
                  rating: review.rating,
                  reviewContent: review.reviewContent,
                  reviewDate: review.reviewDate,
                  likes: review.likes,
                  unlikes: review.unlikes + 1,
                  userId: review.userId,
                );
              }
              return review;
            }).toList();

            emit(ReviewLoaded(
              reviews: updatedReviews,
              hasMoreData: currentState.hasMoreData,
              currentPage: currentState.currentPage,
            ));
          }
        },
        failure: (failure) {
          emit(ReviewActionError(failure.message));
        },
      );
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  Future<void> _onDeleteMovieReview(
    DeleteMovieReview event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final result = await reviewRepository.deleteMovieReview(event.reviewId);
      
      result.when(
        success: (success) {
          emit(ReviewActionSuccess());
          if (success && state is ReviewLoaded) {
            final currentState = state as ReviewLoaded;
            final updatedReviews = currentState.reviews
                .where((review) => review.reviewId != event.reviewId)
                .toList();

            emit(ReviewLoaded(
              reviews: updatedReviews,
              hasMoreData: currentState.hasMoreData,
              currentPage: currentState.currentPage,
            ));
          }
        },
        failure: (failure) {
          emit(ReviewActionError(failure.message));
        },
      );
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  Future<void> _onPostMovieReview(
    PostMovieReview event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final result = await reviewRepository.postMovieReview(event.movieId, event.reviewData);
      
      result.when(
        success: (newReview) {
          emit(ReviewActionSuccess());
          if (state is ReviewLoaded) {
            final currentState = state as ReviewLoaded;
            final updatedReviews = [newReview, ...currentState.reviews];

            emit(ReviewLoaded(
              reviews: updatedReviews,
              hasMoreData: currentState.hasMoreData,
              currentPage: currentState.currentPage,
            ));
          } else {
            // If no reviews were loaded before, create a new loaded state
            emit(ReviewLoaded(
              reviews: [newReview],
              hasMoreData: false,
              currentPage: 1,
            ));
          }
        },
        failure: (failure) {
          emit(ReviewActionError(failure.message));
        },
      );
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  Future<void> _onUpdateMovieReview(
    UpdateMovieReview event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final result = await reviewRepository.updateMovieReview(event.reviewId, event.reviewData);
      
      result.when(
        success: (updatedReview) {
          emit(ReviewActionSuccess());
          if (state is ReviewLoaded) {
            final currentState = state as ReviewLoaded;
            final updatedReviews = currentState.reviews.map((review) {
              if (review.reviewId == event.reviewId) {
                return updatedReview;
              }
              return review;
            }).toList();

            emit(ReviewLoaded(
              reviews: updatedReviews,
              hasMoreData: currentState.hasMoreData,
              currentPage: currentState.currentPage,
            ));
          }
        },
        failure: (failure) {
          emit(ReviewActionError(failure.message));
        },
      );
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }
}
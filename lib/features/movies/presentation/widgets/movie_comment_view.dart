// lib/features/movies/presentation/pages/enhanced_movie_comment_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/core/utils/snackbar_utilies.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_action_handler.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_event.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_state.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/review_item.dart';
import 'review_widget.dart';

class EnhancedMovieCommentView extends StatefulWidget {
  final MovieModel movie;

  const EnhancedMovieCommentView({
    super.key,
    required this.movie,
  });

  @override
  State<EnhancedMovieCommentView> createState() => _EnhancedMovieCommentViewState();
}

class _EnhancedMovieCommentViewState extends State<EnhancedMovieCommentView>
    with TickerProviderStateMixin {
  static const int _maxLoadMoreCount = 3;
  int _loadMoreCount = 0;
  late AnimationController _fabController;
  late ReviewActionHandler _reviewHandler;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _loadReviews();
  }

  void _initializeComponents() {
    _reviewHandler = ReviewActionHandler(
      context: context,
      movie: widget.movie,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabController.forward();
  }

  void _loadReviews() {
    context.read<ReviewBloc>().add(
      LoadMovieReviews(movieId: widget.movie.movieId),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _handleLoadMore() {
    setState(() {
      _loadMoreCount++;
    });
    context.read<ReviewBloc>().add(
      LoadMovieReviews(
        movieId: widget.movie.movieId,
        loadMore: true,
      ),
    );
  }

  void _handleLoadAll() {
    context.read<ReviewBloc>().add(
      LoadAllMovieReviews(movieId: widget.movie.movieId),
    );
  }

  void _handleRetry() {
    context.read<ReviewBloc>().add(
      LoadMovieReviews(movieId: widget.movie.movieId),
    );
  }

  Widget _buildLoadMoreSection(ReviewLoaded state) {
    if (!state.hasMoreData) return const SizedBox.shrink();

    if (_loadMoreCount < _maxLoadMoreCount) {
      return ReviewWidgets.buildLoadMoreButton(
        context,
        _handleLoadMore,
        'review.loadMore'.i18n(),
      );
    } else {
      return ReviewWidgets.buildLoadAllButton(
        context,
        _handleLoadAll,
      );
    }
  }

  Widget _buildReviewsList(ReviewLoaded state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: state.reviews.length,
      itemBuilder: (context, index) {
        final review = state.reviews[index];
        return EnhancedReviewItem(
          review: review,
          onLike: () => _reviewHandler.handleLikeReview(review.reviewId),
          onDislike: () => _reviewHandler.handleUnlikeReview(review.reviewId),
          onDelete: () => _reviewHandler.handleDeleteReview(review.reviewId),
          // onReport: () => _reviewHandler.handleReportReview(review.reviewId),
        );
      },
    );
  }

  Widget _buildContent(ReviewState state) {
    // Loading state
    if (state is ReviewInitial || 
        (state is ReviewLoading && state is! ReviewLoaded)) {
      return ReviewWidgets.buildLoadingState(context);
    }
    
    // Error state
    if (state is ReviewError) {
      return ReviewWidgets.buildErrorState(
        context,
        state.message,
        _handleRetry,
      );
    }
    
    // Loaded state
    if (state is ReviewLoaded) {
      if (state.reviews.isEmpty) {
        return ReviewWidgets.buildEmptyState(
          context,
          _reviewHandler.handleAddReview,
        );
      }
      
      return Column(
        children: [
          _buildReviewsList(state),
          _buildLoadMoreSection(state),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewActionError) {
          SnackbarUtils.showErrorSnackbar(context, state.message);
        }
        if (state is ReviewActionSuccess) {
          SnackbarUtils.showSuccessSnackbar(
            context, 
            'Thao tác thành công',
          );
        }
      },
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          final reviewCount = state is ReviewLoaded ? state.reviews.length : 0;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              ReviewWidgets.buildHeader(
                context,
                reviewCount,
                _fabController,
                _reviewHandler.handleAddReview,
              ),
              
              // Main content
              _buildContent(state),
              
              // Bottom spacing
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
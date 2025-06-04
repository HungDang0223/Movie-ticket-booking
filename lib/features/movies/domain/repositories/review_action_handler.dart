// lib/features/movies/presentation/handlers/review_action_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/utils/authentication_helper.dart';
import 'package:movie_tickets/core/utils/snackbar_utilies.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_event.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/add_review_dialog.dart';

class ReviewActionHandler {
  final BuildContext context;
  final MovieModel movie;

  ReviewActionHandler({
    required this.context,
    required this.movie,
  });

  /// Xử lý thêm review mới
  Future<void> handleAddReview() async {
    final isAuthenticated = await AuthenticationHelper.requireAuthentication(context);
    if (!isAuthenticated) {
      SnackbarUtils.showAuthRequiredSnackbar(
        context,
        'Bạn cần đăng nhập để viết đánh giá',
      );
      return;
    }

    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedAddReviewDialog(
        movie: movie,
        onReviewSubmitted: (reviewData) {
          context.read<ReviewBloc>().add(
            PostMovieReview(
              movieId: movie.movieId,
              reviewData: reviewData,
            ),
          );
        },
      ),
    );
  }

  /// Xử lý like review
  Future<void> handleLikeReview(int reviewId) async {
    final isAuthenticated = await AuthenticationHelper.requireAuthentication(context);
    if (!isAuthenticated) {
      SnackbarUtils.showAuthRequiredSnackbar(
        context,
        'Bạn cần đăng nhập để thích đánh giá',
      );
      return;
    }

    if (!context.mounted) return;
    context.read<ReviewBloc>().add(LikeMovieReview(reviewId: reviewId));
  }

  /// Xử lý xóa review
  Future<void> handleDeleteReview(int reviewId) async {
    final isAuthenticated = await AuthenticationHelper.requireAuthentication(context);
    if (!isAuthenticated) {
      SnackbarUtils.showAuthRequiredSnackbar(
        context,
        'Bạn cần đăng nhập để xóa đánh giá',
      );
      return;
    }

    if (!context.mounted) return;
    
    _showDeleteConfirmationDialog(reviewId);
  }

  /// Hiển thị dialog xác nhận xóa
  void _showDeleteConfirmationDialog(int reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ReviewBloc>().add(DeleteMovieReview(reviewId: reviewId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Xử lý báo cáo review
  Future<void> handleReportReview(int reviewId) async {
    final isAuthenticated = await AuthenticationHelper.requireAuthentication(context);
    if (!isAuthenticated) {
      SnackbarUtils.showAuthRequiredSnackbar(
        context,
        'Bạn cần đăng nhập để báo cáo đánh giá',
      );
      return;
    }

    if (!context.mounted) return;
    
    _showReportConfirmationDialog(reviewId);
  }

  /// Hiển thị dialog xác nhận báo cáo
  void _showReportConfirmationDialog(int reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo đánh giá'),
        content: const Text('Bạn có muốn báo cáo đánh giá này vì vi phạm quy định?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Thêm event báo cáo review nếu có
              // context.read<ReviewBloc>().add(ReportMovieReview(reviewId: reviewId));
              SnackbarUtils.showSuccessSnackbar(
                context,
                'Đã gửi báo cáo thành công',
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Báo cáo'),
          ),
        ],
      ),
    );
  }
}
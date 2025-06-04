import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';

class EnhancedReviewItem extends StatelessWidget {
  final MovieReview review;
  final VoidCallback onLike;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReport;

  const EnhancedReviewItem({
    super.key,
    required this.review,
    required this.onLike,
    this.onDelete,
    this.onEdit, this.onReport,
  });

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildActionButton({
    required int count,
    bool isLiked = false,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border_outlined,
              size: 16,
              color: isLiked ? AppColor.DEFAULT_2 : AppColor.GRAY1,
            ),
            const SizedBox(width: 4),
            Text(
              "Yêu thích",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: review.photoPath.isNotEmpty
                    ? NetworkImage(review.photoPath)
                    : null,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: review.photoPath.isEmpty
                    ? Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.isCurrentUser ? "Bạn" : review.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildRatingStars(review.rating),
                        const SizedBox(width: 8),
                        Text(
                        _formatDate(review.reviewDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildActionButton(count: review.likes, onPressed: onLike),
              // Menu for edit/delete actions
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'report':
                        onReport?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    if (onReport != null)
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.report_gmailerrorred_outlined, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Report', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Review content
          Text(
            review.reviewContent,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
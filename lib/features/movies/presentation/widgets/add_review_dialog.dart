import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/start_rating_selector.dart';
import '../../../../core/constants/app_color.dart';
import '../../data/models/review_model.dart';

class EnhancedAddReviewDialog extends StatefulWidget {
  final MovieModel movie;
  final Function(Map<String, dynamic>) onReviewSubmitted;

  const EnhancedAddReviewDialog({
    super.key,
    required this.movie,
    required this.onReviewSubmitted,
  });

  @override
  State<EnhancedAddReviewDialog> createState() => _EnhancedAddReviewDialogState();
}

class _EnhancedAddReviewDialogState extends State<EnhancedAddReviewDialog>
    with TickerProviderStateMixin {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_selectedRating == 0) {
      _showSnackBar('Please select a rating', Colors.orange);
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      _showSnackBar('Please write a review', Colors.orange);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reviewData = {
      'userId': 1,
      'movieId': widget.movie.movieId,
      'rating': _selectedRating,
      'reviewContent': _reviewController.text.trim(),
      'reviewDate': DateTime.now().toIso8601String(),
      // Add other required fields based on your API requirements
    };

    // Call the callback with the review data
    widget.onReviewSubmitted(reviewData);
    
    Navigator.of(context).pop();
  }

  void _closeDialog() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildMovieHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.movie, size: 30),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "review.writeReview".i18n(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.movie.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              EnhancedStarRatingSelector(
                onRatingSelected: (rating) {
                  setState(() {
                    _selectedRating = rating;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'review.addComment'.i18n(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'review.commentHint'.i18n(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isSubmitting ? null : _closeDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'common.cancel'.i18n(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Text(
                  '${'common.submit'.i18n()} ${'review.review'.i18n()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMovieHeader(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingSection(),
                      const SizedBox(height: 24),
                      _buildReviewSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Star Rating Selector
class EnhancedStarRatingSelector extends StatefulWidget {
  final Function(int) onRatingSelected;

  const EnhancedStarRatingSelector({
    super.key,
    required this.onRatingSelected,
  });

  @override
  State<EnhancedStarRatingSelector> createState() => _EnhancedStarRatingSelectorState();
}

class _EnhancedStarRatingSelectorState extends State<EnhancedStarRatingSelector>
    with TickerProviderStateMixin {
  int _rating = 0;
  int _hoverRating = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _rating;
        final isHovered = starIndex <= _hoverRating;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _hoverRating = starIndex),
          onExit: (_) => setState(() => _hoverRating = 0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _rating = starIndex;
              });
              _scaleController.forward().then((_) {
                _scaleController.reverse();
              });
              widget.onRatingSelected(_rating);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              child: ScaleTransition(
                scale: (isSelected || isHovered) ? _scaleAnimation : 
                       const AlwaysStoppedAnimation(1.0),
                child: Icon(
                  isSelected || isHovered ? Icons.star : Icons.star_border,
                  size: 40.0,
                  color: isSelected || isHovered ? Colors.amber : Colors.grey[400],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
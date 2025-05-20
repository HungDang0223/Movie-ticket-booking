import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_tickets/features/movies/data/models/review_model.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/review_item.dart';

class MovieCommentView extends StatefulWidget {
  final int movieId;

  const MovieCommentView({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieCommentView> createState() => _MovieCommentViewState();
}

class _MovieCommentViewState extends State<MovieCommentView> {
  final List<MovieReview> _reviews = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 5;
  int _loadMoreCount = 0;
  final int _maxLoadMoreCount = 3;

  @override
  void initState() {
    super.initState();
    _loadMoreReviews();
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newReviews = await fetchMovieReviews(
        widget.movieId,
        _currentPage,
        _pageSize,
      );

      setState(() {
        _reviews.addAll(newReviews);
        _currentPage++;
        _isLoading = false;
        _hasMoreData = newReviews.length == _pageSize;
        
        if (_hasMoreData) {
          _loadMoreCount++;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading reviews: $e');
    }
  }

  void _loadAllReviews() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<MovieReview> allRemainingReviews = [];
      bool hasMore = true;
      int page = _currentPage;

      while (hasMore) {
        final newReviews = await fetchMovieReviews(
          widget.movieId,
          page,
          _pageSize,
        );
        
        allRemainingReviews.addAll(newReviews);
        page++;
        hasMore = newReviews.length == _pageSize;
      }

      setState(() {
        _reviews.addAll(allRemainingReviews);
        _currentPage = page;
        _isLoading = false;
        _hasMoreData = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading all reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Comments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (_reviews.isEmpty && !_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No comments yet. Be the first to comment!'),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return ReviewItem(review: review);
          },
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
        if (_hasMoreData && _loadMoreCount < _maxLoadMoreCount)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loadMoreReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Load More'),
              ),
            ),
          ),
        if (_hasMoreData && _loadMoreCount >= _maxLoadMoreCount)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loadAllReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('See All Comments'),
              ),
            ),
          ),
      ],
    );
  }
}

Future<List<MovieReview>> fetchMovieReviews(int movieId, int page, int pageSize) async {
    // In a real app, this would be an API call
    // For demonstration, we'll simulate a delay and return mock data
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data for demonstration
    final List<Map<String, dynamic>> mockData = [
      {
        "reviewId": 1,
        "userId": "00574115fc2911efa84fc0f489ce6fbe",
        "fullName": "John Doe",
        "photoPath": null,
        "movieId": 1,
        "rating": 5,
        "reviewContent": "An amazing movie, loved every moment!",
        "reviewDate": "2025-04-28T09:42:44",
        "likes": 15,
        "unlikes": 2
      },
      {
        "reviewId": 2,
        "userId": "10574115fc2911efa84fc0f489ce6fbe",
        "fullName": "Jane Smith",
        "photoPath": null,
        "movieId": 1,
        "rating": 4,
        "reviewContent": "Great plot and characters, but the ending was a bit rushed.",
        "reviewDate": "2025-04-27T14:22:10",
        "likes": 8,
        "unlikes": 1
      },
      {
        "reviewId": 3,
        "userId": "20574115fc2911efa84fc0f489ce6fbe",
        "fullName": "Mike Johnson",
        "photoPath": null,
        "movieId": 1,
        "rating": 3,
        "reviewContent": "Decent film but I expected more from the director.",
        "reviewDate": "2025-04-26T18:15:30",
        "likes": 5,
        "unlikes": 3
      },
      {
        "reviewId": 4,
        "userId": "30574115fc2911efa84fc0f489ce6fbe",
        "fullName": "Sara Williams",
        "photoPath": null,
        "movieId": 1,
        "rating": 5,
        "reviewContent": "One of the best movies I've seen this year! The cinematography is stunning.",
        "reviewDate": "2025-04-25T11:05:12",
        "likes": 20,
        "unlikes": 0
      },
      {
        "reviewId": 5,
        "userId": "40574115fc2911efa84fc0f489ce6fbe",
        "fullName": "David Brown",
        "photoPath": null,
        "movieId": 1,
        "rating": 4,
        "reviewContent": "Very entertaining with great performances from the cast.",
        "reviewDate": "2025-04-24T16:43:55",
        "likes": 12,
        "unlikes": 1
      },
      {
        "reviewId": 6,
        "userId": "50574115fc2911efa84fc0f489ce6fbe",
        "fullName": "Emma Davis",
        "photoPath": null,
        "movieId": 1,
        "rating": 5,
        "reviewContent": "I was on the edge of my seat the entire time! Fantastic movie.",
        "reviewDate": "2025-04-23T20:32:18",
        "likes": 18,
        "unlikes": 2
      },
      {
        "reviewId": 7,
        "userId": "60574115fc2911efa84fc0f489ce6fbe",
        "fullName": "Robert Wilson",
        "photoPath": null,
        "movieId": 1,
        "rating": 2,
        "reviewContent": "Too predictable and clichéd for my taste.",
        "reviewDate": "2025-04-22T08:12:40",
        "likes": 3,
        "unlikes": 7
      },
    ];
    
    // Calculate start and end indices for pagination
    final startIndex = page * pageSize;
    final endIndex = startIndex + pageSize;
    
    // Return paginated data
    final paginatedData = mockData.length > startIndex
        ? mockData.sublist(
            startIndex, 
            endIndex < mockData.length ? endIndex : mockData.length
          )
        : [];
    
    return paginatedData.map((json) => MovieReview.fromJson(json)).toList();
  }
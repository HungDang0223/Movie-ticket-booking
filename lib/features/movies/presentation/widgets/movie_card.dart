import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

class MovieCard extends StatefulWidget {
  final List<MovieModel> movies;
  // Thêm callback để thông báo khi trang thay đổi
  final Function(int)? onPageChanged;

  MovieCard({
    required this.movies,
    this.onPageChanged, // Tham số tùy chọn
  });

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  late PageController _pageController;
  double _currentPage = 0.0;

  // match censor with xx+
  String getCensor(String censor) {
    switch (censor) {
      case "P":
        return "P";
      case "C13":
        return "13+";
      case "C16":
        return "16+";
      case "C18":
        return "18+";
      default:
        return "13+";
    }
  }
  
  @override
  void initState() {
    super.initState();
    // Sử dụng số lượng bội của mảng movies để cải thiện trải nghiệm vô hạn
    int initialPage = widget.movies.length * 10;
    
    _pageController = PageController(
      viewportFraction: 0.65,
      initialPage: initialPage,
    );
    
    // Thiết lập giá trị ban đầu cho _currentPage
    _currentPage = initialPage.toDouble();
    
    // Lắng nghe sự thay đổi trang để cập nhật _currentPage
    _pageController.addListener(_onPageChanged);
    
    // Kích hoạt animation ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Cập nhật để kích hoạt rebuild
        });
        
        // Thông báo trang ban đầu cho parent widget
        if (widget.onPageChanged != null) {
          widget.onPageChanged!(initialPage % widget.movies.length);
        }
      }
    });
  }
  
  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page ?? _currentPage;
    });
    
    // Thông báo cho parent widget khi trang thay đổi
    if (widget.onPageChanged != null && _pageController.page != null) {
      int currentIndex = _pageController.page!.round() % widget.movies.length;
      widget.onPageChanged!(currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      // Thêm onPageChanged event để đảm bảo bắt được cả khi user kéo nhanh
      onPageChanged: (index) {
        if (widget.onPageChanged != null) {
          widget.onPageChanged!(index % widget.movies.length);
        }
      },
      itemBuilder: (context, index) {
        int actualIndex = index % widget.movies.length;
        final movie = widget.movies[actualIndex];
        
        // Tính toán giá trị transform cho từng card
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
        } else {
          // Khi chưa có dimensions, sử dụng giá trị từ _currentPage
          value = _currentPage - index;
        }
        
        // Giảm hiệu ứng nghiêng và scale cho gần nhau hơn
        double tilt = (1 - (value.abs() * 0.2)).clamp(0.85, 1.0);
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((value) * math.pi / 8) // Giảm góc xoay
            ..scale(tilt),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed('/movie_detail', arguments: movie),
            child: Opacity(
              opacity: tilt,
              child: Stack(
                children: [
                  // Movie poster container
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(movie.posterUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 25,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.DEFAULT_2,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        getCensor(movie.censor),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Number indicator
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Text(
                      "${actualIndex + 1}",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.85),
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
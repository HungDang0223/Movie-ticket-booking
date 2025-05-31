import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/booking/presentation/pages/booking_showing_movie.dart';
import 'dart:math' as math;

import 'package:movie_tickets/features/venues/data/models/cinema.dart';

class CinemaDetailPage extends StatefulWidget {
  final Cinema cinema;
  
  const CinemaDetailPage({
    Key? key,
    required this.cinema,
  }) : super(key: key);

  @override
  State<CinemaDetailPage> createState() => _CinemaDetailPageState();
}

class _CinemaDetailPageState extends State<CinemaDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      bool isCollapsed = _scrollController.offset > 200;
      if (isCollapsed != _isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = isCollapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildCinemaHeader(),
                    _buildQuickActions(),
                    _buildCinemaInfo(),
                    _buildLocationSection(),
                    _buildContactSection(),
                    _buildShowingMoviesButton(),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(),
            _buildGradientOverlay(),
            _buildImageContent(),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {
              // Handle favorite action
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // Handle share action
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return widget.cinema.imagePath.isNotEmpty
        ? Image.network(
            widget.cinema.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderHeroImage();
            },
          )
        : _buildPlaceholderHeroImage();
  }

  Widget _buildPlaceholderHeroImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.DEFAULT_2,
            AppColor.DEFAULT,
            AppColor.DEFAULT_5,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.DEFAULT,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Premium Cinema',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.cinema.cinemaName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.cinema.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColor.DEFAULT, AppColor.DEFAULT_2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_movies,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cinema.cinemaName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Premium Experience',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingWidget(),
              ],
            ),
            const SizedBox(height: 20),
            _buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.DEFAULT.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                '4.8',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            '1.2k reviews',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.chair, 'label': 'Premium Seats'},
      {'icon': Icons.surround_sound, 'label': 'Dolby Atmos'},
      {'icon': Icons.local_parking, 'label': 'Free Parking'},
      {'icon': Icons.restaurant, 'label': 'Food Court'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.DEFAULT.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: AppColor.DEFAULT,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.directions,
              title: 'Directions',
              subtitle: '2.5 km away',
              onTap: () => _openMaps(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.phone,
              title: 'Call',
              subtitle: widget.cinema.hotline,
              onTap: () => _makeCall(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.DEFAULT.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColor.DEFAULT,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Cinema',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the ultimate movie viewing with state-of-the-art technology, premium seating, and exceptional service. Our cinema offers the perfect environment for an unforgettable entertainment experience.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildOperatingHours(),
        ],
      ),
    );
  }

  Widget _buildOperatingHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: AppColor.DEFAULT, size: 20),
              SizedBox(width: 8),
              Text(
                'Operating Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHourRow('Monday - Thursday', '10:00 AM - 11:00 PM'),
          _buildHourRow('Friday - Sunday', '9:00 AM - 12:00 AM'),
          _buildHourRow('Public Holidays', '9:00 AM - 12:00 AM'),
        ],
      ),
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            hours,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: AppColor.DEFAULT, size: 24),
              SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.cinema.location,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildMapPreview(),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 40,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to view full map',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openMaps(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_phone, color: AppColor.DEFAULT, size: 24),
              SizedBox(width: 8),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Hotline',
            value: widget.cinema.hotline,
            onTap: () => _makeCall(),
          ),
          _buildContactItem(
            icon: Icons.fax,
            title: 'Fax',
            value: widget.cinema.fax,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.DEFAULT.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColor.DEFAULT, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not available',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: AppColor.DEFAULT,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShowingMoviesButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.DEFAULT, AppColor.DEFAULT_2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.DEFAULT.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShowingMovieBookingScreen(
                cinema: widget.cinema,
                movie: null,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.movie_filter,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 16),
                const Text(
                  'View Showing Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 200,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.DEFAULT_2, AppColor.DEFAULT],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColor.DEFAULT.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShowingMovieBookingScreen(
                cinema: widget.cinema,
                movie: null,
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_movies,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Book Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMaps() {
    // Open maps with cinema location
    // You can use url_launcher to open Google Maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening maps...'),
        backgroundColor: AppColor.DEFAULT,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _makeCall() {
    // Make phone call
    // You can use url_launcher to make calls
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${widget.cinema.hotline}...'),
        backgroundColor: AppColor.DEFAULT,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
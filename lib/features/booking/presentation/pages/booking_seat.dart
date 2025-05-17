import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/entities/movie.dart';
import '../../data/models/models.dart';
import 'booking_snack.dart';

class Seat {
  final String id;
  final bool isBooked;
  final String type; // 'regular', 'vip', 'sweetbox'

  Seat({
    required this.id,
    required this.isBooked,
    required this.type,
  });
}

class BookingSeatScreen extends StatefulWidget {
  final MovieModel movie;
  final ShowingMovie showingMovie;

  const BookingSeatScreen({
    Key? key,
    required this.movie,
    required this.showingMovie,
  }) : super(key: key);

  @override
  State<BookingSeatScreen> createState() => _BookingSeatScreenState();
}

class _BookingSeatScreenState extends State<BookingSeatScreen> with SingleTickerProviderStateMixin {
  // Selected seats
  List<String> selectedSeats = [];
  double totalPrice = 0;
  late TransformationController _transformationController;
  late AnimationController _animationController;
  
  // Seat prices by type
  final Map<String, double> seatPrices = {
    'regular': 75000,
    'vip': 95000,
    'sweetbox': 120000,
  };

  // Seat layout data structure
  Map<String, List<Seat>> seatLayout = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    fetchSeatLayout();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void resetZoom() {
    // Calculate scale to fit all content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox;
      final viewportSize = renderBox.size;
      final viewportWidth = viewportSize.width;
      final viewportHeight = viewportSize.height * 0.7; // Adjust for bottom area
      
      // Estimate the content size based on seat layout
      final maxSeatsInRow = seatLayout.values.map((seats) => seats.length).reduce((a, b) => a > b ? a : b);
      final rowCount = seatLayout.length;
      
      // Calculate content width and height (with some padding)
      final contentWidth = maxSeatsInRow * 52.0 + 50.0; // 52 = seat width + margins
      final contentHeight = rowCount * 48.0 + 150.0; // 48 = row height, 150 for screen and margins
      
      // Calculate scale to fit
      final scaleX = viewportWidth / contentWidth;
      final scaleY = viewportHeight / contentHeight;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      
      // Apply scale with slight adjustment for better fit
      final adjustedScale = scale * 0.9;
      
      // Set the transformation
      final Matrix4 matrix = Matrix4.identity()
        ..scale(adjustedScale, adjustedScale);
      
      _transformationController.value = matrix;
    });
  }

  Future<void> fetchSeatLayout() async {
    try {
      // TODO: Replace with actual API call
      final response = {
        'A': List.generate(10, (i) => Seat(id: 'A${i + 1}', isBooked: false, type: 'regular')),
        'B': List.generate(10, (i) => Seat(id: 'B${i + 1}', isBooked: false, type: 'regular')),
        'C': List.generate(8, (i) => Seat(id: 'C${i + 1}', isBooked: false, type: 'regular')),
        'D': List.generate(10, (i) => Seat(id: 'D${i + 1}', isBooked: false, type: 'vip')),
        'E': List.generate(8, (i) => Seat(id: 'E${i + 1}', isBooked: false, type: 'vip')),
        'F': List.generate(10, (i) => Seat(id: 'F${i + 1}', isBooked: false, type: 'vip')),
        'G': List.generate(8, (i) => Seat(id: 'G${i + 1}', isBooked: false, type: 'vip')),
        'H': List.generate(10, (i) => Seat(id: 'H${i + 1}', isBooked: false, type: 'vip')),
        'I': List.generate(8, (i) => Seat(id: 'I${i + 1}', isBooked: false, type: 'vip')),
        'J': List.generate(10, (i) => Seat(id: 'J${i + 1}', isBooked: false, type: 'vip')),
        'K': List.generate(14, (i) => Seat(id: 'K${i + 1}', isBooked: false, type: 'sweetbox')),
      };

      setState(() {
        seatLayout = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu ghế ngồi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleSeatSelection(String seatId) {
    final row = seatId[0];
    final seat = seatLayout[row]?.firstWhere((s) => s.id == seatId);
    
    if (seat == null || seat.isBooked) return;

    setState(() {
      if (selectedSeats.contains(seatId)) {
        selectedSeats.remove(seatId);
        totalPrice -= seatPrices[seat.type]!;
      } else {
        selectedSeats.add(seatId);
        totalPrice += seatPrices[seat.type]!;
      }
    });
  }

  Color getSeatColor(String row, String seatId) {
    final seat = seatLayout[row]?.firstWhere((s) => s.id == seatId);
    
    if (seat == null) return Colors.grey;
    
    if (seat.isBooked) {
      return const Color(0xFFE0E0E0);
    }
    
    if (selectedSeats.contains(seatId)) {
      return const Color(0xFF4CAF50);
    }
    
    switch (seat.type) {
      case 'regular':
        return const Color(0xFFF5E6E8);
      case 'vip':
        return const Color(0xFFE8F5E9);
      case 'sweetbox':
        return const Color(0xFFFFF3E0);
      default:
        return Colors.grey;
    }
  }

  void proceedToSnacks() {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ghế'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SnackSelectionScreen(
          movieTitle: widget.movie.title,
          theaterName: widget.showingMovie.cinemaName,
          showTime: "${widget.showingMovie.startTime} - ${widget.showingMovie.endTime}",
          showDate: widget.showingMovie.showingDate.toIso8601String(),
          selectedSeats: selectedSeats,
          ticketPrice: totalPrice,
        ),
      ),
    );
  }

  Widget _buildScreen() {
    return Container(
      width: 300, // Fixed width to ensure the screen is centered
      height: 40,
      margin: const EdgeInsets.only(top: 20, bottom: 40), // Add more space below the screen
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: const Center(
        child: Text(
          'MÀN HÌNH',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // Seat legend with wrap that prioritizes horizontal layout
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate if items can fit in a single row
          final itemWidth = 90.0; // Estimated width per legend item
          final availableWidth = constraints.maxWidth;
          final itemsPerRow = (availableWidth / itemWidth).floor();
          
          // If we can fit all 5 items in a row, use Row, otherwise use a specific split
          if (itemsPerRow >= 5) {
            // All items in one row
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(const Color(0xFF4CAF50), 'Đang chọn'),
                _buildLegendItem(Colors.grey.shade400, 'Đã đặt'),
                _buildLegendItem(const Color(0xFFF5E6E8), 'Thường'),
                _buildLegendItem(const Color(0xFFE8F5E9), 'VIP'),
                _buildLegendItem(const Color(0xFFFFF3E0), 'Sweet Box'),
              ],
            );
          } else {
            // Split 3 items on first row, 2 items on second row
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(const Color(0xFF4CAF50), 'Đang chọn'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.grey.shade400, 'Đã đặt'),
                    const SizedBox(width: 16),
                    _buildLegendItem(const Color(0xFFF5E6E8), 'Thường'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(const Color(0xFFE8F5E9), 'VIP'),
                    const SizedBox(width: 16),
                    _buildLegendItem(const Color(0xFFFFF3E0), 'Sweet Box'),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'CGV ',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.showingMovie.cinemaName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Cinema 5, ${widget.showingMovie.showingDate}, ${widget.showingMovie.startTime}-${widget.showingMovie.endTime}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.red),
              onPressed: resetZoom,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : Column(
              children: [
                // Seat layout container
                Expanded(
                  child: Stack(
                    children: [
                      InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.5,
                        maxScale: 2.0,
                        boundaryMargin: const EdgeInsets.all(150),
                        constrained: false,
                        onInteractionEnd: (_) {
                          setState(() {}); // Refresh state to update minimap
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Screen indicator
                                _buildScreen(),
                                const SizedBox(height: 20),
                                // Seat layout
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Row labels column
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: seatLayout.keys.map((row) => Container(
                                          height: 44,
                                          width: 25,
                                          margin: const EdgeInsets.symmetric(vertical: 2),
                                          alignment: Alignment.center,
                                          child: Text(
                                            row,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )).toList(),
                                      ),
                                      const SizedBox(width: 10),
                                      // Seats grid
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: seatLayout.entries.map((entry) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: _buildSeatRow(entry.key, entry.value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Mini-map in top-left corner that shows a scaled view of the seats
                      _buildMiniMap(),
                    ],
                  ),
                ),
                
                // Seat legend
                _buildLegend(),
                
                // Movie info and booking button
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '2D Phụ Đề Anh',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: proceedToSnacks,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                              elevation: 3,
                              shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                            child: const Text(
                              'ĐẶT VÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRow(String row, List<Seat> seats) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: seats.map((seat) {
        return GestureDetector(
          onTap: () => toggleSeatSelection(seat.id),
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: getSeatColor(row, seat.id),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedSeats.contains(seat.id)
                    ? const Color(0xFF4CAF50)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                seat.id,
                style: TextStyle(
                  color: selectedSeats.contains(seat.id)
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Mini-map in top-left corner that shows a scaled view of the seats
  Widget _buildMiniMap() {
    // Calculate the current visible area based on transformation
    final Matrix4 transform = _transformationController.value;
    final double scale = transform.getMaxScaleOnAxis();
    
    // Simplified view - just show the seats with current position highlighted
    return Positioned(
      left: 16,
      top: 16,
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini screen
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Center(
                    child: Text(
                      'MÀN HÌNH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Current view scale indicator
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.withOpacity(0.5), width: 0.5),
                  ),
                  child: Text(
                    'Scale: ${scale.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Mini seat layout
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row headers and seats
                      ...seatLayout.entries.map((entry) => Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Row label
                          Container(
                            width: 8,
                            height: 7,
                            alignment: Alignment.center,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Seats
                          ...entry.value.map((seat) => Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: selectedSeats.contains(seat.id)
                                  ? const Color(0xFF4CAF50)
                                  : getSeatColor(entry.key, seat.id),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


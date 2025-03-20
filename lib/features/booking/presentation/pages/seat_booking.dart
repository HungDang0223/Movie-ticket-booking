import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'snack_booking.dart';

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

class SeatBookingScreen extends StatefulWidget {
  final String movieTitle;
  final String theaterName;
  final String showTime;
  final String showDate;

  const SeatBookingScreen({
    Key? key,
    required this.movieTitle,
    required this.theaterName,
    required this.showTime,
    required this.showDate,
  }) : super(key: key);

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> with SingleTickerProviderStateMixin {
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
      duration: Duration(milliseconds: 300),
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
    _transformationController.value = Matrix4.identity();
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
      return Color(0xFFE0E0E0);
    }
    
    if (selectedSeats.contains(seatId)) {
      return Color(0xFF4CAF50);
    }
    
    switch (seat.type) {
      case 'regular':
        return Color(0xFFF5E6E8);
      case 'vip':
        return Color(0xFFE8F5E9);
      case 'sweetbox':
        return Color(0xFFFFF3E0);
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
          movieTitle: widget.movieTitle,
          theaterName: widget.theaterName,
          showTime: widget.showTime,
          showDate: widget.showDate,
          selectedSeats: selectedSeats,
          ticketPrice: totalPrice,
        ),
      ),
    );
  }

  Widget _buildScreen() {
    return Container(
      width: double.infinity,
      height: 40,
      margin: EdgeInsets.only(bottom: 10),
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
      child: Center(
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

  @override
  Widget build(BuildContext context) {
    // Calculate the total width needed for seats
    final maxSeatsInRow = seatLayout.values.map((seats) => seats.length).reduce((a, b) => a > b ? a : b);
    final seatWidth = 32.0;
    final seatMargin = 4.0;
    final wayWidth = 48.0;
    final wayMargin = 4.0;
    final waysCount = seatLayout.values.length;
    
    // Calculate total width including seats, ways, and margins
    final totalWidth = (maxSeatsInRow * (seatWidth + seatMargin)) + 
                      (waysCount * (wayWidth + wayMargin));
    
    // Calculate scale factor to fit the screen
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth - 64) / totalWidth; // 64 for row labels and padding

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'CGV ',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.theaterName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Cinema 5, ${widget.showDate}, ${widget.showTime}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.red),
              onPressed: resetZoom,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : Column(
              children: [
                // Screen indicator and seat layout container
                Expanded(
                  child: Stack(
                    children: [
                      // Seat layout
                      InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.5,
                        maxScale: 2.0,
                        boundaryMargin: EdgeInsets.all(double.infinity),
                        child: Column(
                          children: [
                            // Screen
                            _buildScreen(),
                            // Row labels and seats
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row labels column
                                    Container(
                                      width: 32,
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        children: seatLayout.keys.map((row) => Container(
                                          height: 32,
                                          margin: EdgeInsets.symmetric(vertical: 2),
                                          child: Text(
                                            row,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )).toList(),
                                      ),
                                    ),
                                    // Seats grid
                                    Expanded(
                                      child: Column(
                                        children: seatLayout.entries.map((entry) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2),
                                            child: _buildSeatRow(entry.key, entry.value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Mini screen indicator (overlay)
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Transform.scale(
                          scale: _transformationController.value.getMaxScaleOnAxis(),
                          child: Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFF4CAF50), width: 2),
                              color: Colors.black.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    'MÀN HÌNH',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                      mainAxisSpacing: 1,
                                      crossAxisSpacing: 1,
                                    ),
                                    itemCount: 64,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 2,
                                        height: 2,
                                        color: index < 48 ? Colors.white : Colors.pink,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Seat legend
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Color(0xFF4CAF50), 'Đang chọn'),
                      _buildLegendItem(Colors.grey.shade400, 'Đã đặt'),
                      _buildLegendItem(Color(0xFFF5E6E8), 'Thường'),
                      _buildLegendItem(Color(0xFFE8F5E9), 'VIP'),
                      _buildLegendItem(Color(0xFFFFF3E0), 'Sweet Box'),
                    ],
                  ),
                ),
                
                // Movie info and booking button
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movieTitle,
                        style: TextStyle(
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
                              Text(
                                '2D Phụ Đề Anh',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(0)} đ',
                                style: TextStyle(
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
                              backgroundColor: Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                              elevation: 3,
                              shadowColor: Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                            child: Text(
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
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
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: seats.map((seat) {
          return GestureDetector(
            onTap: () => toggleSeatSelection(seat.id),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 32,
              height: 32,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: getSeatColor(row, seat.id),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedSeats.contains(seat.id)
                      ? Color(0xFF4CAF50)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


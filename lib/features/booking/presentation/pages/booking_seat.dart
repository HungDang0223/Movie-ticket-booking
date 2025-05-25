import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/constants/enums.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_bloc.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_event.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_state.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/injection.dart';
import '../../data/models/models.dart';
import 'booking_snack.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/booking/data/models/models.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:movie_tickets/features/booking/data/models/showing_seat.dart';
import 'booking_snack.dart';

class BookingSeatPage extends StatefulWidget {
  final MovieModel movie;
  final ShowingMovie showingMovie;
  final String websocketUrl;
  final String? userId;

  const BookingSeatPage({
    super.key,
    required this.movie,
    required this.showingMovie,
    required this.websocketUrl,
    this.userId,
  });

  @override
  State<BookingSeatPage> createState() => _BookingSeatPageState();
}

class _BookingSeatPageState extends State<BookingSeatPage> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late BookingSeatBloc _bookingSeatBloc;
  
  // Seat prices by type
  final Map<String, double> seatPrices = {
    'Regular': 75000,
    'VIP': 95000,
    'Sweet Box': 120000,
  };

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

    // Store bloc reference
    _bookingSeatBloc = context.read<BookingSeatBloc>();
    
    // Initialize BLoC events
    _initializeBooking();
  }

  void _initializeBooking() {
    // Use stored bloc reference
    _bookingSeatBloc.add(ConnectToRealtimeEvent(widget.websocketUrl));
    _bookingSeatBloc.add(JoinShowingEvent(widget.showingMovie.showingId, userId: widget.userId));
    _bookingSeatBloc.add(LoadSeatsEvent(widget.showingMovie.screenId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingSeatBloc = context.read<BookingSeatBloc>();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    
    // Use stored bloc reference
    _bookingSeatBloc.add(const DisconnectEvent());
    super.dispose();
  }

  void resetZoom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      
      final viewportSize = renderBox.size;
      final viewportWidth = viewportSize.width;
      final viewportHeight = viewportSize.height * 0.7;
      
      // Calculate content dimensions based on available seats
      final bloc = context.read<BookingSeatBloc>();
      final state = bloc.state;
      
      if (state.rowSeats.isNotEmpty) {
        final maxSeatsInRow = state.rowSeats.map((row) => row.seats.length).reduce((a, b) => a > b ? a : b);
        final rowCount = state.rowSeats.length;
        
        final contentWidth = maxSeatsInRow * 52.0 + 50.0;
        final contentHeight = rowCount * 48.0 + 150.0;
        
        final scaleX = viewportWidth / contentWidth;
        final scaleY = viewportHeight / contentHeight;
        final scale = (scaleX < scaleY ? scaleX : scaleY) * 0.9;
        
        final Matrix4 matrix = Matrix4.identity()..scale(scale, scale);
        _transformationController.value = matrix;
      }
    });
  }

  void _toggleSeatSelection(int seatId) {
    final state = _bookingSeatBloc.state;

    if (state.selectedSeats.contains(seatId)) {
      _bookingSeatBloc.add(DeselectSeatEvent(seatId));
    } else {
      _bookingSeatBloc.add(SelectSeatEvent(seatId));
    }
  }

  Future<void> _reserveSeats() async {
    final state = _bookingSeatBloc.state;
    
    if (state.selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ghế'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Reserve each selected seat
    for (final seatId in state.selectedSeats) {
      final request = ReserveSeatRequest(
        showingId: widget.showingMovie.showingId,
        seatId: seatId,
      );
      _bookingSeatBloc.add(ReserveSeatEvent(request));
    }
  }

  void _proceedToSnacks() {
    final state = _bookingSeatBloc.state;
    
    if (state.selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ghế'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalPrice = _calculateTotalPrice(state);
    final selectedSeatNames = _getSelectedSeatNames(state);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SnackSelectionScreen(
          movieTitle: widget.movie.title,
          theaterName: widget.showingMovie.cinemaName,
          showTime: "${widget.showingMovie.startTime} - ${widget.showingMovie.endTime}",
          showDate: widget.showingMovie.showingDate.toIso8601String(),
          selectedSeats: selectedSeatNames,
          ticketPrice: totalPrice,
        ),
      ),
    );
  }

  double _calculateTotalPrice(BookingSeatState state) {
    double total = 0;
    for (final seatId in state.selectedSeats) {
      final seat = _findSeatById(state, seatId);
      if (seat != null) {
        // total += seatPrices[seat.seatType] ?? 0;
        // Tạm thời
        total += 10000; // Assuming seatType is a valid key in seatPrices
      }
    }
    return total;
  }

  List<String> _getSelectedSeatNames(BookingSeatState state) {
    final names = <String>[];
    for (final seatId in state.selectedSeats) {
      final seat = _findSeatById(state, seatId);
      if (seat != null) {
        final rowName = _findRowNameBySeatId(state, seatId);
        names.add('$rowName${seat.seatNumber}');
      }
    }
    return names;
  }

  SetDto? _findSeatById(BookingSeatState state, int seatId) {
    for (final row in state.rowSeats) {
      for (final seat in row.seats) {
        if (seat.seatId == seatId) {
          return seat;
        }
      }
    }
    return null;
  }

  String _findRowNameBySeatId(BookingSeatState state, int seatId) {
    for (final row in state.rowSeats) {
      for (final seat in row.seats) {
        if (seat.seatId == seatId) {
          return row.rowName;
        }
      }
    }
    return '';
  }

  Color _getSeatColor(BookingSeatState state, int seatId, String seatType) {
    // Check if seat is selected
    if (state.selectedSeats.contains(seatId)) {
      return const Color(0xFF4CAF50);
    }
    
    // Check real-time status updates
    final statusUpdate = state.seatStatusUpdates[seatId];
    if (statusUpdate != null) {
      switch (statusUpdate.status) {
        case SeatStatus.Reserved:
          return const Color(0xFFFFB74D);
        case SeatStatus.Sold:
          return const Color(0xFFE0E0E0);
        case SeatStatus.TemporarilyReserved:
          return const Color(0xFFFFB74D);
        case SeatStatus.Available:
          break;
      }
    }
    
    // Default colors by seat type
    switch (seatType) {
      case 'Regular':
        return const Color(0xFFF5E6E8);
      case 'VIP':
        return const Color(0xFFE8F5E9);
      case 'Sweet Box':
        return const Color(0xFFFFF3E0);
      default:
        return Colors.grey;
    }
  }

  bool _isSeatBookable(BookingSeatState state, int seatId) {
    final statusUpdate = state.seatStatusUpdates[seatId];
    if (statusUpdate != null) {
      return statusUpdate.status == SeatStatus.Available;
    }
    return true; // Default to available if no status update
  }

  Widget _buildScreen() {
    return Container(
      width: 300,
      height: 40,
      margin: const EdgeInsets.only(top: 20, bottom: 40),
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

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const itemWidth = 90.0;
          final availableWidth = constraints.maxWidth;
          final itemsPerRow = (availableWidth / itemWidth).floor();
          
          if (itemsPerRow >= 6) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(const Color(0xFF4CAF50), 'Đang chọn'),
                _buildLegendItem(const Color(0xFFE0E0E0), 'Đã đặt'),
                _buildLegendItem(const Color(0xFFFFB74D), 'Tạm giữ'),
                _buildLegendItem(const Color(0xFFF5E6E8), 'Thường'),
                _buildLegendItem(const Color(0xFFE8F5E9), 'VIP'),
                _buildLegendItem(const Color(0xFFFFF3E0), 'Sweet Box'),
              ],
            );
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(const Color(0xFF4CAF50), 'Đang chọn'),
                    const SizedBox(width: 16),
                    _buildLegendItem(const Color(0xFFE0E0E0), 'Đã đặt'),
                    const SizedBox(width: 16),
                    _buildLegendItem(const Color(0xFFFFB74D), 'Tạm giữ'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(const Color(0xFFF5E6E8), 'Thường'),
                    const SizedBox(width: 16),
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

  Widget _buildSeatRow(BookingSeatState state, RowSeatsDto rowData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowData.seats.map((seat) {
        final isBookable = _isSeatBookable(state, seat.seatId);
        final seatColor = _getSeatColor(state, seat.seatId, rowData.seatType);
        final isSelected = state.selectedSeats.contains(seat.seatId);
        
        return GestureDetector(
          onTap: isBookable ? () => _toggleSeatSelection(seat.seatId) : null,
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: seatColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : isBookable
                        ? Colors.grey.shade300
                        : Colors.grey.shade500,
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
                '${rowData.rowName}${seat.seatNumber}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isBookable
                          ? Colors.black87
                          : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConnectionStatus(String status) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'connected':
        statusColor = AppColor.DEFAULT;
        statusText = 'Kết nối';
        break;
      case 'connecting':
        statusColor = Colors.orange;
        statusText = 'Đang kết nối...';
        break;
      case 'disconnected':
        statusColor = Colors.red;
        statusText = 'Mất kết nối';
        break;
      default:
        statusColor = Colors.red;
        statusText = 'Lỗi kết nối';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            icon: const Icon(Icons.arrow_back_ios, color: AppColor.DEFAULT),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.showingMovie.cinemaName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.showingMovie.screenName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<BookingSeatBloc, BookingSeatState>(
              builder: (context, state) {
                return _buildConnectionStatus(state.connectionStatus ?? 'connecting');
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.red),
              onPressed: resetZoom,
            ),
          ],
        ),
      ),
      body: BlocConsumer<BookingSeatBloc, BookingSeatState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          if (state.status == BookingSeatStatus.reserved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ghế đã được đặt thành công!'),
                backgroundColor: AppColor.GREEN,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BookingSeatStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.DEFAULT),
              ),
            );
          }
          
          if (state.status == BookingSeatStatus.error && state.rowSeats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải dữ liệu ghế ngồi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Đã xảy ra lỗi',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookingSeatBloc>().add(
                        LoadSeatsEvent(widget.showingMovie.screenId),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              // Seat layout container
              Expanded(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 2.0,
                  boundaryMargin: const EdgeInsets.all(150),
                  constrained: false,
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
                          if (state.rowSeats.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Row labels column
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: state.rowSeats.map((rowData) => Container(
                                      height: 44,
                                      width: 25,
                                      margin: const EdgeInsets.symmetric(vertical: 2),
                                      alignment: Alignment.center,
                                      child: Text(
                                        rowData.rowName,
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
                                    children: state.rowSeats.map((rowData) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: _buildSeatRow(state, rowData),
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
                            Text(
                              '${widget.showingMovie.showingFormat} Phụ Đề ${widget.showingMovie.subtitleLanguage}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${widget.showingMovie.showingDate.toFormattedString()}, ${widget.showingMovie.startTime.HH_mm()}-${widget.showingMovie.endTime.HH_mm()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_calculateTotalPrice(state).toStringAsFixed(0)} đ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (state.selectedSeats.isNotEmpty)
                              Text(
                                'Ghế đã chọn: ${_getSelectedSeatNames(state).join(', ')}',
                                style: const TextStyle(
                                  color: AppColor.DEFAULT,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            if (state.status == BookingSeatStatus.reserving ||
                                state.status == BookingSeatStatus.confirming ||
                                state.status == BookingSeatStatus.canceling)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: state.selectedSeats.isNotEmpty ? () async {
                                  await _reserveSeats();
                                  // Nếu ghế chưa có ai đặt thì chuyển sang trang đặt đồ ăn
                                  if (state.errorMessage == null) {
                                    
                                    _proceedToSnacks();
                                  }
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  disabledBackgroundColor: Colors.grey,
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/constants/enums.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_bloc.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_event.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_state.dart';
import 'package:movie_tickets/features/booking/presentation/widgets/connection_state_widget.dart';
import 'package:movie_tickets/features/booking/presentation/widgets/legend_widget.dart';
import 'package:movie_tickets/features/booking/presentation/widgets/screen_widget.dart';
import 'package:movie_tickets/features/booking/presentation/widgets/seat_row_widget.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/injection.dart';
import '../../data/models/models.dart';
import 'booking_snack.dart';

class BookingSeatPage extends StatefulWidget {
  final String websocketUrl;
  final MovieModel movie;
  final ShowingMovie showingMovie;
  final String userId;

  const BookingSeatPage({
    Key? key,
    required this.websocketUrl,
    required this.movie,
    required this.showingMovie,
    required this.userId,
  }) : super(key: key);

  @override
  _BookingSeatPageState createState() => _BookingSeatPageState();
}

class _BookingSeatPageState extends State<BookingSeatPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late BookingSeatBloc _bookingSeatBloc;

  bool _hasReservedSeats = false;
  List<int> _userReservedSeats = [];
  
  // Seat prices by type
  final Map<String, double> seatPrices = {
    'Regular': 75000,
    'VIP': 95000,
    'Couple': 120000,
  };

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addObserver(this);
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
    // Initialize in the correct order
    _bookingSeatBloc.add(ConnectToRealtimeEvent(widget.websocketUrl));
    _bookingSeatBloc.add(JoinShowingEvent(widget.showingMovie.showingId, userId: widget.userId));
    _bookingSeatBloc.add(LoadSeatsEvent(widget.showingMovie.screenId));
    // Load seat statuses for this specific showing
    _bookingSeatBloc.add(LoadSeatStatusesEvent(widget.showingMovie.showingId));
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
    _bookingSeatBloc.add(const DisconnectEvent());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Clean up seats when app goes to background or is paused
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      _performSeatCleanup();
    }
  }

  // Override the back button behavior
  Future<bool> _onWillPop() async {
    await _performSeatCleanup();
    return true; // Allow navigation
  }

  Future<void> _performSeatCleanup() async {
    if (_hasReservedSeats && _userReservedSeats.isNotEmpty) {
      print('Performing seat cleanup for seats: $_userReservedSeats');
      
      _bookingSeatBloc.add(ReleaseUserSeatsEvent(
        userId: widget.userId,
        showingId: widget.showingMovie.showingId,
      ));
      
      _hasReservedSeats = false;
      _userReservedSeats.clear();
    }
  }

  void resetZoom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      
      final viewportSize = renderBox.size;
      final viewportWidth = viewportSize.width;
      final viewportHeight = viewportSize.height * 0.7;
      
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

    // Use the helper method to check if seat is bookable
    if (!state.isSeatBookable(seatId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ghế này không thể đặt'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

    // Check if any selected seats are no longer available
    for (final seatId in state.selectedSeats) {
      if (!state.isSeatBookable(seatId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ghế ${_getSeatDisplayName(state, seatId)} không còn khả dụng'),
            backgroundColor: Colors.red,
          ),
        );
        // Remove unavailable seat from selection
        _bookingSeatBloc.add(DeselectSeatEvent(seatId));
        return;
      }
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
        total += 10000; // Use your actual pricing logic
      }
    }
    return total;
  }

  List<String> _getSelectedSeatNames(BookingSeatState state) {
    final names = <String>[];
    for (final seatId in state.selectedSeats) {
      names.add(_getSeatDisplayName(state, seatId));
    }
    return names;
  }

  String _getSeatDisplayName(BookingSeatState state, int seatId) {
    final seat = _findSeatById(state, seatId);
    if (seat != null) {
      final rowName = _findRowNameBySeatId(state, seatId);
      return '$rowName${seat.seatNumber}';
    }
    return 'Unknown';
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

  Widget _buildScreen() => const Screen();


  Widget _buildLegend() => const LegendWidget();


  Widget _buildSeatRow(BookingSeatState state, RowSeatsDto rowData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowData.seats.map((seat) {
        final isBookable = state.isSeatBookable(seat.seatId);
        final seatColor = _getSeatColor(state, seat.seatId, rowData.seatType);
        final isSelected = state.selectedSeats.contains(seat.seatId);
        final effectiveStatus = state.getEffectiveSeatStatus(seat.seatId);
        
        return GestureDetector(
          onTap: isBookable ? () => _toggleSeatSelection(seat.seatId) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isSelected ? 6 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '${rowData.rowName}${seat.seatNumber}',
                    style: TextStyle(
                      color: AppColor.WHITE,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getSeatColor(BookingSeatState state, int seatId, String seatType) {
    // Check if seat is selected by current user
    if (state.selectedSeats.contains(seatId)) {
      return const Color(0xFF4CAF50); // Green for selected
    }
    
    // Use the helper method to get effective status
    final effectiveStatus = state.getEffectiveSeatStatus(seatId);
    
    switch (effectiveStatus) {
      case SeatStatus.Reserved:
        return const Color(0xFFFFB74D); // Orange for reserved
      case SeatStatus.Sold:
        return const Color(0xFFE0E0E0); // Gray for sold
      case SeatStatus.TempReserved:
        return const Color(0xFFFF8A65); // Light orange for temporarily reserved
      case SeatStatus.Available:
        // Return color based on seat type for available seats
        switch (seatType) {
          case 'Regular':
            return const Color.fromARGB(255, 178, 145, 123);
          case 'VIP':
            return const Color.fromARGB(255, 135, 23, 51);
          case 'Couple':
            return AppColor.DEFAULT_2;
          default:
            return const Color(0xFFF5E6E8);
        }
    }
  }
    
  Widget _buildConnectionStatus(String status) => ConnectionStateWidget(status: status);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => 
        didPop ? _performSeatCleanup() : Future.value(),
      child: Scaffold(
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
                Text(
                  widget.showingMovie.cinemaName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
            if (state.hasNewError && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Đóng',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
              context.read<BookingSeatBloc>().add(const ClearErrorEvent());
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
            // Show loading while data is not ready
            if (!state.isDataReady && state.status == BookingSeatStatus.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.DEFAULT),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu ghế ngồi...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                      onPressed: () => _initializeBooking(),
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
                            _buildScreen(),
                            const SizedBox(height: 20),
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
                                        height: 48,
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
                          Expanded(
                            child: Column(
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
                                Row(
                                  children: [
                                    Text(
                                  '${_calculateTotalPrice(state).toStringAsFixed(0)} đ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (state.selectedSeats.isNotEmpty)
                                  Text(
                                    '${_getSelectedSeatNames(state).length} ghế',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
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
      ),
    );
  }
}


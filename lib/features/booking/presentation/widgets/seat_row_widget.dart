import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/constants/enums.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_state.dart';

class SeatRowWidget extends StatelessWidget {
  final RowSeatsDto rowData;
  final BookingSeatState state;
  final Function(int seatId) toggleSeatSelection;
  const SeatRowWidget({super.key, required this.rowData, required this.state, required this.toggleSeatSelection});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowData.seats.map((seat) {
        final isBookable = state.isSeatBookable(seat.seatId);
        final seatColor = _getSeatColor(state, seat.seatId, rowData.seatType);
        final isSelected = state.selectedSeats.contains(seat.seatId);
        final effectiveStatus = state.getEffectiveSeatStatus(seat.seatId);
        
        return GestureDetector(
          onTap: isBookable ? () => toggleSeatSelection(seat.seatId) : null,
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
}
  
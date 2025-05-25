import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildLegendItem(AppColor.SEAT_SELECTED, 'Đang chọn'),
                _buildLegendItem(AppColor.SEAT_SOLD, 'Đã bán'),
                _buildLegendItem(AppColor.SEAT_RESERVED, 'Đã đặt'),
                _buildLegendItem(AppColor.SEAT_TEMP_RESERVED, 'Tạm giữ'),
                _buildLegendItem(AppColor.SEAT_REGULAR, 'Thường'),
                _buildLegendItem(AppColor.SEAT_VIP, 'VIP'),
              ],
            );
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(AppColor.SEAT_SELECTED, 'Đang chọn'),
                    const SizedBox(width: 16),
                    _buildLegendItem(AppColor.SEAT_SOLD, 'Đã bán'),
                    const SizedBox(width: 16),
                    _buildLegendItem(AppColor.SEAT_RESERVED, 'Đã đặt'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(AppColor.SEAT_TEMP_RESERVED, 'Đang giữ ghế'),
                    const SizedBox(width: 16),
                    _buildLegendItem(AppColor.SEAT_REGULAR, 'Thường'),
                    const SizedBox(width: 16),
                    _buildLegendItem(AppColor.SEAT_VIP, 'VIP'),
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
}
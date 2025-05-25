import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';

class ConnectionStateWidget extends StatelessWidget {
  final String status;
  const ConnectionStateWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case 'connected':
        statusColor = AppColor.GREEN;
        statusText = 'Kết nối';
        statusIcon = Icons.wifi;
        break;
      case 'connecting':
        statusColor = Colors.orange;
        statusText = 'Đang kết nối...';
        statusIcon = Icons.wifi_outlined;
        break;
      case 'disconnected':
        statusColor = Colors.red;
        statusText = 'Mất kết nối';
        statusIcon = Icons.wifi_off;
        break;
      default:
        statusColor = Colors.red;
        statusText = 'Lỗi kết nối';
        statusIcon = Icons.error_outline;
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
          Icon(
            statusIcon,
            color: statusColor,
            size: 12,
          ),
          const SizedBox(width: 4),
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
}
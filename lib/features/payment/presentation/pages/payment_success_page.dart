import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String movieTitle;
  final String theaterName;
  final String showDate;
  final String showTime;
  final List<String> selectedSeats;
  final String transactionId;

  const PaymentSuccessPage({
    Key? key,
    required this.movieTitle,
    required this.theaterName,
    required this.showDate,
    required this.showTime,
    required this.selectedSeats,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Vé đã thanh toán',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success icon and message
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 70,
              ),
              SizedBox(height: 16),
              Text(
                'Thanh toán thành công!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Cảm ơn bạn đã mua vé',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),

              // Ticket card with QR
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ticket info section
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16),
                          _buildTicketInfoRow(Icons.location_on, theaterName),
                          _buildTicketInfoRow(Icons.calendar_today, showDate),
                          _buildTicketInfoRow(Icons.access_time, showTime),
                          _buildTicketInfoRow(
                            Icons.event_seat, 
                            'Ghế: ${selectedSeats.join(", ")}',
                          ),
                          _buildTicketInfoRow(
                            Icons.confirmation_number,
                            'Mã đặt vé: ${transactionId}',
                          ),
                        ],
                      ),
                    ),

                    // Divider with dots
                    Row(
                      children: List.generate(30, (index) => 
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    
                    // QR code section
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Image.network(
                                'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${Uri.encodeComponent(transactionId)}',
                                width: 180,
                                height: 180,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.qr_code,
                                  size: 150,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Quét mã QR này tại rạp để lấy vé',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement download ticket
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                      icon: Icon(Icons.download),
                      label: Text('Lưu vé'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement share ticket
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                      icon: Icon(Icons.share),
                      label: Text('Chia sẻ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Back to home button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'QUAY VỀ TRANG CHỦ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
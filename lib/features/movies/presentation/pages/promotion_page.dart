import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';

class PromotionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Quảng cáo và ưu đãi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.DEFAULT),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chia sẻ khuyến mãi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Container(
              width: double.infinity,
              height: 250,
              child: Image.asset(
                'assets/images/banners/banner1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ảnh không tải được',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'assets/images/banners/banner1.jpg',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên promotion
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'KHUYẾN MÃI ĐĂC BIỆT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'HAPPY WEDNESDAY - THỨ TƯ VUI VẺ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Đồng giá vé mọi loại ghế, mọi suất chiếu chỉ từ 45.000 VNĐ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Thể lệ
                  _buildSectionCard(
                    title: 'Thể lệ chương trình',
                    icon: Icons.rule,
                    iconColor: Colors.blue,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint('Khách hàng mua vé xem phim vào các ngày thứ Tư sẽ được áp dụng giá ưu đãi'),
                        _buildBulletPoint('Áp dụng cho tất cả các loại ghế: Standard, VIP, Couple, Premium'),
                        _buildBulletPoint('Áp dụng cho tất cả các suất chiếu trong ngày thứ Tư'),
                        _buildBulletPoint('Khách hàng có thể đặt vé trước qua ứng dụng TICKAT hoặc tại quầy'),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Thời gian
                  _buildSectionCard(
                    title: 'Thời gian áp dụng',
                    icon: Icons.schedule,
                    iconColor: Colors.orange,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Mỗi thứ Tư hàng tuần',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Tất cả các suất chiếu trong ngày',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            'Chương trình kéo dài đến hết năm 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Rạp áp dụng
                  _buildSectionCard(
                    title: 'Rạp áp dụng',
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Áp dụng tại TẤT CẢ các cụm rạp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Danh sách một số cụm rạp tiêu biểu:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'CGV Vincom',
                            'Galaxy Cinema',
                            'BHD Star',
                            'Lotte Cinema',
                            'Mega GS',
                            'CineStar',
                            'Dcine',
                            'Beta Cinema',
                          ].map((cinema) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              cinema,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Điều kiện
                  _buildSectionCard(
                    title: 'Điều kiện áp dụng',
                    icon: Icons.info_outline,
                    iconColor: Colors.purple,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint('Chỉ áp dụng vào các ngày thứ Tư trong tuần'),
                        _buildBulletPoint('Không áp dụng vào các ngày lễ, Tết, và các sự kiện đặc biệt'),
                        _buildBulletPoint('Số lượng vé khuyến mãi có hạn, bán theo thứ tự ưu tiên'),
                        _buildBulletPoint('Giá vé có thể thay đổi tùy theo từng cụm rạp và khu vực'),
                        _buildBulletPoint('Không áp dụng đồng thời với các chương trình khuyến mãi khác'),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Điều khoản
                  _buildSectionCard(
                    title: 'Điều khoản và điều kiện',
                    icon: Icons.gavel,
                    iconColor: Colors.red,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint('TICKAT có quyền thay đổi, tạm ngưng hoặc kết thúc chương trình mà không cần báo trước'),
                        _buildBulletPoint('Khách hàng cần xuất trình vé hợp lệ khi vào rạp xem phim'),
                        _buildBulletPoint('Vé đã mua không được hoàn lại hoặc đổi trả, trừ trường hợp hủy suất chiếu'),
                        _buildBulletPoint('Mọi tranh chấp phát sinh sẽ được giải quyết theo quy định của pháp luật Việt Nam'),
                        _buildBulletPoint('Bằng việc tham gia chương trình, khách hàng đồng ý với các điều khoản trên'),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Action Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Chuyển đến trang đặt vé'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.movie_creation, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'ĐẶT VÉ NGAY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
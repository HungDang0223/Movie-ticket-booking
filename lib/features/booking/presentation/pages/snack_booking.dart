import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnackItem {
  final String name;
  final String description;
  final double price;
  final String image;
  final bool hasPromotion;
  final String promotionText;
  int quantity;

  SnackItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.hasPromotion = false,
    this.promotionText = '',
    this.quantity = 0,
  });
}

class SnackSelectionScreen extends StatefulWidget {
  final String movieTitle;
  final String theaterName;
  final String showTime;
  final String showDate;
  final List<String> selectedSeats;
  final double ticketPrice;

  const SnackSelectionScreen({
    Key? key,
    required this.movieTitle,
    required this.theaterName,
    required this.showTime,
    required this.showDate,
    required this.selectedSeats,
    required this.ticketPrice,
  }) : super(key: key);

  @override
  State<SnackSelectionScreen> createState() => _SnackSelectionScreenState();
}

class _SnackSelectionScreenState extends State<SnackSelectionScreen> {
  List<SnackItem> snacks = [
    SnackItem(
      name: 'SNAKE MINI BROWN & FRIENDS SET',
      description: '03 ly thiết kế nhân vật Snake Mini Brown & Friends\nCó ngay: 01 Bắp mix hai vị và 02 Nước ngọt siêu lớn, kèm 01 snack ...',
      price: 569000,
      image: 'assets/images/snake_mini_set.png',
      hasPromotion: true,
      promotionText: 'Có ngay',
    ),
    SnackItem(
      name: 'COMBO OF THE MONTH MAR25',
      description: '01 ly nhân vật (không kèm nước) + 01 Bắp ngọt lớn + 01 Nước ngọt siêu lớn\n- Tặng 01 Thẻ quà tặng trị giá 50.000VND',
      price: 219000,
      image: 'assets/images/combo_month.png',
      hasPromotion: false,
    ),
    SnackItem(
      name: 'PREMIUM MY COMBO',
      description: '1 Bắp Ngọt Lớn + 1 Nước Siêu Lớn + 1 Snack\n- Áp dụng giá Lễ, Tết cho các sản phẩm bắp nước đối với giao dịch có suất chiếu vào n...',
      price: 115000,
      image: 'assets/images/premium_combo.png',
      hasPromotion: false,
    ),
    SnackItem(
      name: 'MY COMBO',
      description: '1 Bắp Ngọt Lớn + 1 Nước Siêu Lớn\n- Áp dụng giá Lễ, Tết cho các sản phẩm bắp nước đối với giao dịch có suất chiếu vào ngày Lễ, Tết ...',
      price: 95000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
    ),
    SnackItem(
      name: 'SNAKE MINI BROWN & FRIENDS SINGLE COMBO',
      description: '01 ly thiết kế nhân vật Snake Mini Brown & Friends + 01 Bắp ngọt lớn + 01 Nước ngọt siêu lớn',
      price: 249000,
      image: 'assets/images/snake_mini_single.png',
      hasPromotion: true,
      promotionText: 'Có ngay',
    ),
  ];

  double get snackTotal {
    return snacks.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get grandTotal {
    return widget.ticketPrice + snackTotal;
  }

  void updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = snacks[index].quantity + change;
      if (newQuantity >= 0) {
        snacks[index].quantity = newQuantity;
      }
    });
  }

  void proceedToPayment() {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng tiền: ${grandTotal.toStringAsFixed(0)} đ'),
            SizedBox(height: 8),
            Text('Bạn có muốn tiếp tục thanh toán?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, navigate to payment screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thanh toán thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC4302B),
            ),
            child: Text('THANH TOÁN'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set status bar color to match the app
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      text: 'Vincom Đà Nẵng',
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
              icon: Icon(Icons.menu, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Promotion banner
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Color(0xFFF44336),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/popcorn_icon.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.fastfood,
                    color: Colors.yellow,
                    size: 40,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Áp dụng giá Lễ, Tết cho các sản phẩm bắp nước đối với giao dịch có suất chiếu vào ngày Lễ, Tết.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Snack list
          Expanded(
            child: ListView.builder(
              itemCount: snacks.length,
              itemBuilder: (context, index) {
                final snack = snacks[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Snack image with promotion tag
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                snack.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade800,
                                  child: Icon(
                                    Icons.fastfood,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            if (snack.hasPromotion)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    snack.promotionText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 16),
                        
                        // Snack details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snack.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${snack.price.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                snack.description,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              
                              // Quantity controls
                              Row(
                                children: [
                                  
                                  Container(
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.remove, color: Colors.black),
                                      iconSize: 12,
                                      onPressed: () => updateQuantity(index, -1),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${snack.quantity}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      shape: BoxShape.rectangle
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.add, color: Colors.black),
                                      iconSize: 12,
                                      onPressed: () => updateQuantity(index, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Movie info and payment button
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VIETNAMESE CONCERT FILM: CHÚNG TA LÀ ...',
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
                          '${grandTotal.toStringAsFixed(0)} đ  ${widget.selectedSeats.length} ghế',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC4302B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'THANH TOÁN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
}


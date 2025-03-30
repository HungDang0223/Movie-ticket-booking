import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../payment/presentation/pages/payment_page.dart';

class SnackItem {
  final String name;
  final String description;
  final double price;
  final String image;
  final bool hasPromotion;
  final String promotionText;
  final String category;
  final String? subcategory;
  int quantity;

  SnackItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.subcategory,
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

class _SnackSelectionScreenState extends State<SnackSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkoutAnimation;
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Tất cả';
  bool _showCheckoutBar = false;

  List<SnackItem> snacks = [
    SnackItem(
      name: 'SNAKE MINI BROWN & FRIENDS SET',
      description: '03 ly thiết kế nhân vật Snake Mini Brown & Friends\nCó ngay: 01 Bắp mix hai vị và 02 Nước ngọt siêu lớn, kèm 01 snack',
      price: 569000,
      image: 'assets/images/snake_mini_set.png',
      hasPromotion: true,
      promotionText: 'Có ngay',
      category: 'Bộ sưu tập',
      subcategory: 'Bộ sưu tập giới hạn',
    ),
    SnackItem(
      name: 'COMBO OF THE MONTH MAR25',
      description: '01 ly nhân vật (không kèm nước) + 01 Bắp ngọt lớn + 01 Nước ngọt siêu lớn\n- Tặng 01 Thẻ quà tặng trị giá 50.000VND',
      price: 219000,
      image: 'assets/images/combo_month.png',
      hasPromotion: false,
      category: 'Combo',
      subcategory: 'Combo tháng',
    ),
    SnackItem(
      name: 'PREMIUM MY COMBO',
      description: '1 Bắp Ngọt Lớn + 1 Nước Siêu Lớn + 1 Snack\n- Áp dụng giá Lễ, Tết cho các sản phẩm bắp nước đối với giao dịch có suất chiếu vào n...',
      price: 115000,
      image: 'assets/images/premium_combo.png',
      hasPromotion: false,
      category: 'Combo',
      subcategory: 'Combo tiêu chuẩn',
    ),
    SnackItem(
      name: 'MY COMBO',
      description: '1 Bắp Ngọt Lớn + 1 Nước Siêu Lớn\n- Áp dụng giá Lễ, Tết cho các sản phẩm bắp nước đối với giao dịch có suất chiếu vào ngày Lễ, Tết',
      price: 95000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Combo',
      subcategory: 'Combo tiêu chuẩn',
    ),
    SnackItem(
      name: 'SNAKE MINI BROWN & FRIENDS SINGLE COMBO',
      description: '01 ly thiết kế nhân vật Snake Mini Brown & Friends + 01 Bắp ngọt lớn + 01 Nước ngọt siêu lớn',
      price: 249000,
      image: 'assets/images/snake_mini_single.png',
      hasPromotion: true,
      promotionText: 'Có ngay',
      category: 'Bộ sưu tập',
      subcategory: 'Bộ sưu tập giới hạn',
    ),
    // Popcorn sizes
    SnackItem(
      name: 'BẮP CARAMEL NHỎ',
      description: 'Bắp rang caramel thơm ngon, phù hợp để xem phim - Size nhỏ',
      price: 45000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Bắp',
      subcategory: 'Bắp ngọt',
    ),
    SnackItem(
      name: 'BẮP CARAMEL VỪA',
      description: 'Bắp rang caramel thơm ngon, phù hợp để xem phim - Size vừa',
      price: 55000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Bắp',
      subcategory: 'Bắp ngọt',
    ),
    SnackItem(
      name: 'BẮP CARAMEL LỚN',
      description: 'Bắp rang caramel thơm ngon, phù hợp để xem phim - Size lớn',
      price: 65000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Bắp',
      subcategory: 'Bắp ngọt',
    ),
    SnackItem(
      name: 'BẮP MẶN NHỎ',
      description: 'Bắp rang mặn thơm ngon, phù hợp để xem phim - Size nhỏ',
      price: 45000, 
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Bắp',
      subcategory: 'Bắp mặn',
    ),
    SnackItem(
      name: 'BẮP MẶN VỪA',
      description: 'Bắp rang mặn thơm ngon, phù hợp để xem phim - Size vừa',
      price: 55000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Bắp',
      subcategory: 'Bắp mặn',
    ),
    SnackItem(
      name: 'BẮP MẶN LỚN',
      description: 'Bắp rang mặn thơm ngon, phù hợp để xem phim - Size lớn',
      price: 65000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Bắp',
      subcategory: 'Bắp mặn',
    ),
    SnackItem(
      name: 'BẮP MIX HAI VỊ (NGỌT & MẶN)',
      description: 'Bắp rang mix hai vị ngọt và mặn, thỏa mãn mọi khẩu vị',
      price: 75000,
      image: 'assets/images/my_combo.png',
      hasPromotion: true,
      promotionText: 'Mới',
      category: 'Bắp',
      subcategory: 'Bắp đặc biệt',
    ),
    // Drinks sizes
    SnackItem(
      name: 'COCA-COLA NHỎ',
      description: 'Nước ngọt Coca-Cola có ga - Size nhỏ 350ml',
      price: 25000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Coca-Cola',
    ),
    SnackItem(
      name: 'COCA-COLA VỪA',
      description: 'Nước ngọt Coca-Cola có ga - Size vừa 500ml',
      price: 35000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Coca-Cola',
    ),
    SnackItem(
      name: 'COCA-COLA LỚN',
      description: 'Nước ngọt Coca-Cola có ga - Size lớn 700ml',
      price: 45000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Coca-Cola',
    ),
    SnackItem(
      name: 'SPRITE NHỎ',
      description: 'Nước ngọt Sprite có ga chanh - Size nhỏ 350ml',
      price: 25000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Sprite',
    ),
    SnackItem(
      name: 'SPRITE VỪA',
      description: 'Nước ngọt Sprite có ga chanh - Size vừa 500ml',
      price: 35000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Sprite',
    ),
    SnackItem(
      name: 'SPRITE LỚN',
      description: 'Nước ngọt Sprite có ga chanh - Size lớn 700ml',
      price: 45000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Sprite',
    ),
    SnackItem(
      name: 'FANTA NHỎ',
      description: 'Nước ngọt Fanta có ga hương cam - Size nhỏ 350ml',
      price: 25000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Fanta',
    ),
    SnackItem(
      name: 'FANTA VỪA',
      description: 'Nước ngọt Fanta có ga hương cam - Size vừa 500ml',
      price: 35000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Fanta',
    ),
    SnackItem(
      name: 'FANTA LỚN',
      description: 'Nước ngọt Fanta có ga hương cam - Size lớn 700ml',
      price: 45000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Fanta',
    ),
    SnackItem(
      name: 'TRÀ ĐÀO CAM SẢ',
      description: 'Thức uống giải khát hương vị đào, cam và sả - Size vừa',
      price: 55000,
      image: 'assets/images/my_combo.png',
      hasPromotion: true,
      promotionText: 'Mới',
      category: 'Nước',
      subcategory: 'Trà trái cây',
    ),
    SnackItem(
      name: 'TRÀ SỮA TRUYỀN THỐNG',
      description: 'Trà sữa truyền thống thơm ngon - Size vừa',
      price: 50000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Trà sữa',
    ),
    SnackItem(
      name: 'NƯỚC SUỐI',
      description: 'Nước tinh khiết Aquafina 500ml',
      price: 20000,
      image: 'assets/images/my_combo.png',
      hasPromotion: false,
      category: 'Nước',
      subcategory: 'Nước suối',
    ),
  ];

  List<String> get categories {
    final cats = snacks.map((e) => e.category).toSet().toList();
    return ['Tất cả', ...cats];
  }

  List<SnackItem> get filteredSnacks {
    if (_selectedCategory == 'Tất cả') {
      return List.from(snacks)..sort((a, b) {
        int catComp = a.category.compareTo(b.category);
        if (catComp != 0) return catComp;
        
        // Compare subcategories if they exist
        if (a.subcategory != null && b.subcategory != null) {
          return a.subcategory!.compareTo(b.subcategory!);
        }
        return 0;
      });
    }
    return snacks
        .where((snack) => snack.category == _selectedCategory)
        .toList()
        ..sort((a, b) {
          if (a.subcategory != null && b.subcategory != null) {
            return a.subcategory!.compareTo(b.subcategory!);
          }
          return 0;
        });
  }

  double get snackTotal {
    return snacks.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get grandTotal {
    return widget.ticketPrice + snackTotal;
  }

  int get totalItems {
    return snacks.fold(0, (sum, item) => sum + item.quantity);
  }

  void updateQuantity(int index, int change) {
    setState(() {
      final snack = snacks[index];
      final newQuantity = snack.quantity + change;
      if (newQuantity >= 0) {
        snack.quantity = newQuantity;
        
        if (totalItems > 0 && !_showCheckoutBar) {
          _showCheckoutBar = true;
          _animationController.forward();
        } else if (totalItems == 0 && _showCheckoutBar) {
          _showCheckoutBar = false;
          _animationController.reverse();
        }
      }
    });
  }

  void proceedToPayment() {
    // Create a map of selected snacks with quantities > 0
    Map<String, int> selectedSnacks = {};
    for (var snack in snacks) {
      if (snack.quantity > 0) {
        selectedSnacks[snack.name] = snack.quantity;
      }
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          movieTitle: widget.movieTitle,
          theaterName: widget.theaterName,
          showDate: widget.showDate,
          showTime: widget.showTime,
          selectedSeats: widget.selectedSeats,
          ticketPrice: widget.ticketPrice,
          selectedSnacks: selectedSnacks,
          snacksPrice: snackTotal,
        ),
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

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _checkoutAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scrollController.addListener(() {
      // Dismiss keyboard when scrolling
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
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
            Stack(
              alignment: Alignment.center,
              children: [
            IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.red),
                  onPressed: totalItems > 0 ? proceedToPayment : null,
                ),
                if (totalItems > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        totalItems.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
          ],
      ),
      ),
      body: Stack(
        children: [
          Column(
        children: [
          // Promotion banner
              _buildPromotionBanner(),
              
              // Recommended items
              if (_selectedCategory == 'Tất cả')
                _buildRecommendedItems(),
              
              // Category tabs
              _buildCategoryTabs(),
              
              // Snack list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 80), // Add padding for the checkout bar
                  itemCount: filteredSnacks.length,
                  itemBuilder: (context, index) {
                    return _buildSnackCard(index);
                  },
                ),
              ),
            ],
          ),
          
          // Floating checkout bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _checkoutAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 0),
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
            child: Row(
              children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tổng cộng',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${grandTotal.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '${widget.selectedSeats.length} ghế · ${totalItems} món',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC4302B), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                height: 100,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/popcorn_icon.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMBO ƯU ĐÃI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                    'Áp dụng giá Lễ, Tết cho các sản phẩm bắp nước đối với giao dịch có suất chiếu vào ngày Lễ, Tết.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(bottom: 8),
            child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
              itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.grey.shade900,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.transparent,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSnackCard(int index) {
    final snack = filteredSnacks[index];
    final actualIndex = snacks.indexOf(snack);
    
    // Check if this is the first item of its subcategory
    bool isFirstOfSubcategory = false;
    if (snack.subcategory != null) {
      if (index == 0) {
        isFirstOfSubcategory = true;
      } else {
        final prevSnack = filteredSnacks[index - 1];
        isFirstOfSubcategory = prevSnack.subcategory != snack.subcategory ||
                                prevSnack.category != snack.category;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show subcategory header if this is the first item
        if (isFirstOfSubcategory && snack.subcategory != null)
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      snack.subcategory!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  _getSubcategoryDescription(snack.subcategory!),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Show snack detail sheet
              _showSnackDetailSheet(snack, actualIndex);
            },
            borderRadius: BorderRadius.circular(12),
                  child: Padding(
              padding: EdgeInsets.all(12),
                    child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Snack image with promotion tag
                  _buildSnackImage(snack),
                  SizedBox(width: 16),
                  
                  // Snack details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF424242),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                snack.category,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (snack.hasPromotion)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  snack.promotionText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          snack.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${snack.price.toStringAsFixed(0)} đ',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        
                        // Quantity controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (snack.quantity > 0) ...[
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () => updateQuantity(actualIndex, -1),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${snack.quantity}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () => updateQuantity(actualIndex, 1),
                              ),
                            ] else
                              _buildAddButton(() => updateQuantity(actualIndex, 1)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnackImage(SnackItem snack) {
    return Container(
                              width: 80,
                              height: 80,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.asset(
              snack.image,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade800,
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        icon: Icon(icon, color: Colors.white, size: 16),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.add, size: 16),
      label: Text('THÊM'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showSnackDetailSheet(SnackItem snack, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  // Snack image
                  Container(
                    height: 200,
                    width: double.infinity,
                              child: Image.asset(
                                snack.image,
                      fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade800,
                                  child: Icon(
                                    Icons.fastfood,
                                    color: Colors.white,
                          size: 64,
                                  ),
                                ),
                              ),
                            ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category and promotion tags
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xFF424242),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  snack.category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                            if (snack.hasPromotion)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    snack.promotionText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                          SizedBox(height: 16),
                          
                          // Name and price
                              Text(
                                snack.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                              fontSize: 22,
                                ),
                              ),
                          SizedBox(height: 8),
                              Text(
                                '${snack.price.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Description
                          Text(
                            'Thông tin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                          SizedBox(height: 8),
                              Text(
                                snack.description,
                                style: TextStyle(
                                  color: Colors.grey,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24),
                          
                          // Quantity
                          Text(
                            'Số lượng',
                            style: TextStyle(
                                      color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDetailQuantityButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  updateQuantity(index, -1);
                                  setModalState(() {});
                                },
                              ),
                                  Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                    ),
                                      child: Text(
                                        '${snack.quantity}',
                                        style: TextStyle(
                                    color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                              _buildDetailQuantityButton(
                                icon: Icons.add,
                                onPressed: () {
                                  updateQuantity(index, 1);
                                  setModalState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Add to cart button
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (snack.quantity == 0) {
                          updateQuantity(index, 1);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: snack.quantity > 0 
                            ? Colors.green 
                            : Colors.red.shade400,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        snack.quantity > 0 
                            ? 'ĐÃ THÊM VÀO GIỎ HÀNG' 
                            : 'THÊM VÀO GIỎ HÀNG',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                  ),
                );
              },
        );
      },
    );
  }

  Widget _buildDetailQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // Add description for each subcategory
  String _getSubcategoryDescription(String subcategory) {
    switch (subcategory) {
      case 'Bắp ngọt':
        return 'Bắp ngọt caramel thơm ngon';
      case 'Bắp mặn':
        return 'Bắp mặn thêm phô mai, thơm ngon không thể cưỡng lại';
      case 'Bắp đặc biệt':
        return 'Sự kết hợp hoàn hảo của hai vị ngọt và mặn';
      case 'Coca-Cola':
        return 'Nước ngọt Coca-Cola có ga, giải khát tuyệt vời';
      case 'Sprite':
        return 'Nước ngọt có ga vị chanh, thanh mát giải nhiệt';
      case 'Fanta':
        return 'Nước ngọt có ga vị cam, tươi mát và thơm ngon';
      case 'Trà trái cây':
        return 'Trà trái cây tươi mát, thơm ngon, giàu vitamin';
      case 'Trà sữa':
        return 'Trà sữa thơm ngon, béo ngậy, thêm trân châu dai dai';
      case 'Nước suối':
        return 'Nước tinh khiết, lựa chọn lành mạnh cho bạn';
      case 'Bộ sưu tập giới hạn':
        return 'Bộ sản phẩm giới hạn, sưu tầm ngay kẻo hết';
      case 'Combo tháng':
        return 'Combo ưu đãi đặc biệt trong tháng này';
      case 'Combo tiêu chuẩn':
        return 'Combo tiết kiệm dành cho mọi người';
      default:
        return '';
    }
  }

  // Build recommended items
  Widget _buildRecommendedItems() {
    // List of recommended item indices from the snacks list
    final List<int> recommendedIndices = [6, 13, 19]; // Customize these indices based on popular items
    
    return Container(
      height: 240,
      padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đề xuất cho bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Phổ biến nhất',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: recommendedIndices.length,
              itemBuilder: (context, index) {
                final snack = snacks[recommendedIndices[index]];
                final actualIndex = recommendedIndices[index];
                
                return Container(
                  width: 140,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _showSnackDetailSheet(snack, actualIndex),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.asset(
                            snack.image,
                            height: 70,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 70,
                              color: Colors.grey.shade800,
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                        
                        // Details
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                                snack.name,
                          style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                          ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                        ),
                              SizedBox(height: 4),
                        Text(
                                '${snack.price.toStringAsFixed(0)} đ',
                          style: TextStyle(
                                  color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 8),
                              snack.quantity > 0
                                  ? Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: Text(
                                        'Đã thêm ${snack.quantity}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () => updateQuantity(actualIndex, 1),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade400,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Thêm',
                        style: TextStyle(
                          color: Colors.white,
                                                fontSize: 10,
                          fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                        ),
                      ),
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
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x88000000), // Đen với độ trong suốt 50%
            Color(0x44000000), // Đen với độ trong suốt 25%
            Colors.transparent, // Hoàn toàn trong suốt
          ],
          stops: [0.0, 0.7, 1.0], // Điều chỉnh vị trí chuyển màu
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Thay AppColor.DEFAULT_2 bằng transparent
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        // Icon drawer bên trái
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // Title ở giữa
        title: const Text(
          'TICKAT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // Actions bên phải
        actions: [
          // Icon chatbot
          InkWell(
            onTap: () {
              // Xử lý khi nhấn chatbot
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: null)));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/icons/bot.png', 
                width: 30, 
                height: 30,
              ),
            ),
          ),
          // Icon person
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // Xử lý khi nhấn profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mở profile'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8), // Padding cuối
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Phiên bản có thể tùy chỉnh độ mờ
class CustomTransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double opacity; // Độ mờ từ 0.0 đến 1.0
  
  const CustomTransparentAppBar({
    Key? key,
    this.opacity = 0.5, // Mặc định 50% độ mờ
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(opacity),
            Colors.black.withOpacity(opacity * 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'TICKAT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              // Xử lý chatbot
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/icons/bot.png', 
                width: 30, 
                height: 30,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mở profile'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

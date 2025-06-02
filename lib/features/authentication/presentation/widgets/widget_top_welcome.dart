import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_logo_findseat.dart';

class WidgetTopWelcome extends StatelessWidget {
  const WidgetTopWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          // const SizedBox(
          //   width: 172,
          //   child: Center(
          //     child: Text(
          //       "TICKAT",
          //       style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
          Text('Chào mừng trở lại', style: AppFont.MEDIUM_WHITE_22),
          Text(' Đăng nhập và trải nghiệm cùng ứng dụng',
              style: AppFont.MEDIUM_WHITE_14),
        ],
      ),
    );
  }
}

import 'package:go_router/go_router.dart';
import 'package:movie_tickets/app.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login/login_page.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_logo_findseat.dart';

class SplashScreen extends StatelessWidget {

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.DEFAULT,
        child: Center(
          child: SizedBox(
            width: 240,
            child: WidgetLogoFindSeat(),
          ),
        ),
      ),
    );
  }
}

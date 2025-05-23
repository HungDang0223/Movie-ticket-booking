import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_logo_findseat.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.DEFAULT,
        child: const Center(
          child: SizedBox(
            width: 240,
            child: WidgetLogoFindSeat(),
          ),
        ),
      ),
    );
  }
}

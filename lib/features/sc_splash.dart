import 'package:movie_tickets/app.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_logo_findseat.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.DEFAULT,
        child: const Center(
          child: SizedBox(
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 40,
      margin: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg-screen.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const SizedBox()
    );
  }
}
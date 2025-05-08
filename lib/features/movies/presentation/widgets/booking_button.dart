import 'package:flutter/material.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';

import '../../../../core/constants/my_const.dart';

class BookingButton extends StatelessWidget {
  const BookingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/showing_movie_booking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.DEFAULT,
              padding: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "ĐẶT VÉ",
              style: MultiDevices.getStyle(
                fontSize: 14,
                color: AppColor.WHITE,
                fontWeight: FontWeight.bold
              ),
            ),
          );
  }
}
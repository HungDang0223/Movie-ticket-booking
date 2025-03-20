import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WidgetLogoFindSeat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo_find_seat.svg',
      colorFilter: const ColorFilter.mode(AppColor.WHITE, BlendMode.srcIn),
    );
  }
}

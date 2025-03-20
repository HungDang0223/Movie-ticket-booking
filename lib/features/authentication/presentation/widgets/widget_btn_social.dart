import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WidgetBtnSocial extends StatelessWidget {
  final Color btnColor;
  final Color borderColor;
  final String socialIcon;
  final String socialName;

  const WidgetBtnSocial({super.key, required this.btnColor, required this.borderColor, required this.socialIcon, required this.socialName});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: btnColor,
            border: Border.all(
              width: 0.2,
              color: borderColor,
            ),
            shape: BoxShape.rectangle),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SvgPicture.asset(
                socialIcon,
                width: 24,
                height: 24,
              ),
            ),
            Text(
              socialName,
              style: AppFont.REGULAR_GRAY4_12,
            )
          ],
        ),
      ),
    );
  }
}

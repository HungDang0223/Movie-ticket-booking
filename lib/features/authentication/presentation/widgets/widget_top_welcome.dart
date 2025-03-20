import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_logo_findseat.dart';

class WidgetTopWelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 172,
          child: WidgetLogoFindSeat(),
        ),
        const SizedBox(height: 20),
        Text('Welcome Buddies', style: AppFont.MEDIUM_WHITE_22),
        Text(' Login to book your seat, I said its your seat',
            style: AppFont.MEDIUM_WHITE_14),
      ],
    );
  }
}

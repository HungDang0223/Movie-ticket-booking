import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
class WidgetBottomSignUp extends StatelessWidget {
  const WidgetBottomSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              'Don\'t have an account ?',
              style: AppFont.REGULAR_WHITE_10,
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/signup');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Sign up',
                  style: AppFont.SEMIBOLD_WHITE_10.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.WHITE
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Text('Here', style: AppFont.SEMIBOLD_WHITE_10),
          ),
        ],
      ),
    );
  }
}

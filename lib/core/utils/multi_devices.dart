import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_tickets/core/configs/size_config.dart';

import '../constants/my_const.dart';

class MultiDevices {
  static const double defaultScale = 797.7;

  ///
  /// Get style
  ///
  static TextStyle getStyle(
      {double? fontSize,
      Color? color,
      TextOverflow? overflow,
      List<Shadow>? shadows,
      FontWeight? fontWeight,
      Color? backgroundColor,
      TextDecoration? textDecoration}) {
    if (fontSize != null) {
      fontSize = getValueByScale(fontSize);
    }

    return TextStyle(
        fontSize: fontSize,
        overflow: overflow,
        shadows: shadows,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor,
        decoration: textDecoration);
  }

  ///
  /// Get value by scale
  ///
  static double getValueByScale(double value) {
    double currentDuongCheo = _getDuongCheo(SizeConfig.screenWidth!, SizeConfig.screenHeight!);
    double scale = currentDuongCheo / defaultScale;

    return value * scale;
  }

  static double _getDuongCheo(double width, double height) {
    return sqrt((width * width) + (height * height));
  }
}

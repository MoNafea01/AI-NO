import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color bluePrimaryColor = Color(0xFF349CFE);
  static const Color appBackgroundColor = Color(0xFFF2F2F2);
  static const Color grey50 = Color(0xFFF2F2F2);
  static const Color grey100 = Color(0xffE6E6E6);
  static const Color grey200 = Color(0xFFCCCCCC);
  static const Color darkGrey = Color(0xFF999999);
  static const Color nodeInterfaceIconColor = Color(0xffD9D9D9);
  static const Color textSecondary = Color(0xFF666666);
  static const Color blackText = Color(0xFF000000);
  static const Color blackText2 = Color(0xFF1A1A1A);

  static List<Color> get nodesColors => [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.teal,
        Colors.indigo,
        Colors.cyan,
        Colors.brown,
        Colors.lightBlue,
        Colors.lime,
        Colors.amber,
        Colors.deepOrange,
        Colors.deepPurple,
        Colors.lightGreen,
        Colors.grey,
        Colors.blueGrey,
        Colors.black,
      ];
}

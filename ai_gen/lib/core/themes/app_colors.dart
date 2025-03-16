import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color bluePrimaryColor = Color(0xFF349CFE);
  static const Color appBackgroundColor = Colors.white;
  static const Color nodeViewBackgroundColor = Colors.white;
  static const Color secondaryBackgroundColor = Color(0xffE6E6E6);

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

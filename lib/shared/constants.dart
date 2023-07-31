import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.pink,
      width: 2.0,
    ),
  ),
);

class Constants {
  static const String Favorite = 'Show only Favorites';
  static const String All = 'Show All Products';

  static const List<String> choices = <String>[
    Favorite,
    All,
  ];
}

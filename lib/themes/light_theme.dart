import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  // brightness: Brightness.light, eror for some reason??
  appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade100,
    secondary: Colors.grey.shade300,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.black),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  textTheme: Typography.blackCupertino,
);

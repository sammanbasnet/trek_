import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    primarySwatch: Colors.red,
    fontFamily: 'Opensans Regular',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 10,color: Colors.white,
        )
      )
    ),
    );

}
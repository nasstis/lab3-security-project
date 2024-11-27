import 'package:flutter/material.dart';

class AppTextButtonTheme {
  AppTextButtonTheme._();

  static TextButtonThemeData getDefault() => TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
}

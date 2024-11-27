import 'package:flutter/material.dart';

class AppInputDecoration {
  AppInputDecoration._();

  static InputDecorationTheme getDefault(BuildContext context) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        borderSide: BorderSide(
          color: Colors.black,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        borderSide: BorderSide(
          color: Colors.deepPurple,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        borderSide: BorderSide(
          color: Colors.red,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        borderSide: BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }
}

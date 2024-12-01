import 'package:flutter/material.dart';
import 'package:password_project/ui/auth/slider_captcha/slider_captcha.dart';

Future<bool> showRecaptcha(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          height: 275,
          child: SliderCaptcha(
            image: Image.asset(
              'assets/images/captcha_image.jpg',
              fit: BoxFit.fitWidth,
            ),
            colorBar: Colors.green,
            colorCaptChar: Colors.grey,
            title: "Slide to Captcha",
            onConfirm: (value) async {
              Navigator.of(context).pop(value);
            },
          ),
        ),
      );
    },
  );

  return result ?? false;
}

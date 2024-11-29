import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:password_project/firebase_options.dart';
import 'package:password_project/ui/auth/login_screen.dart';
import 'package:password_project/utils/theme/theme_data/elevated_button.dart';
import 'package:password_project/utils/theme/theme_data/input_decoration.dart';
import 'package:password_project/utils/theme/theme_data/text_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        textButtonTheme: AppTextButtonTheme.getDefault(),
        inputDecorationTheme: AppInputDecoration.getDefault(context),
        elevatedButtonTheme: AppElevatedButtonTheme.getDefault(),
      ),
      home: LoginScreen(),
    );
  }
}

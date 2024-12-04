import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:password_project/data/data_sources/user_data_source_impl.dart';
import 'package:password_project/firebase_options.dart';
import 'package:password_project/ui/auth/auth_view_model.dart';
import 'package:password_project/ui/auth/login_screen.dart';
import 'package:password_project/ui/home/home_screen.dart';
import 'package:password_project/utils/theme/theme_data/elevated_button.dart';
import 'package:password_project/utils/theme/theme_data/input_decoration.dart';
import 'package:password_project/utils/theme/theme_data/text_button.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(userDataSource: UserDataSourceImpl()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
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
          home: authViewModel.currentUser == null
              ? const LoginScreen()
              : const HomeScreen(),
        );
      },
    );
  }
}

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:password_project/data/data_sources/user_data_source_impl.dart';
import 'package:password_project/firebase_options.dart';
import 'package:password_project/ui/auth/auth_view_model.dart';
import 'package:password_project/ui/auth/login_screen.dart';
import 'package:password_project/ui/auth/reset_password/reset_password.dart';
import 'package:password_project/utils/theme/theme_data/elevated_button.dart';
import 'package:password_project/utils/theme/theme_data/input_decoration.dart';
import 'package:password_project/utils/theme/theme_data/text_button.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
  }

  void _initDeepLinking() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    print(uri.path);
    if (uri.path == '/reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        print('all good');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamed(
            '/reset-password',
            arguments: token,
          );
        });
      }
    }
  }

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
          navigatorKey: navigatorKey, // Attach the NavigatorKey
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/reset-password': (context) => const ResetPassword(),
          },
        );
      },
    );
  }
}

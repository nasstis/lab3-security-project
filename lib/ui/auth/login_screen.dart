import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:password_project/ui/auth/auth_view_model.dart';
import 'package:password_project/ui/auth/components/auth_buttons.dart';
import 'package:password_project/ui/auth/components/login_form.dart';
import 'package:password_project/ui/auth/register_screen.dart';
import 'package:password_project/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _showPassword = ValueNotifier(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _showPassword.dispose();
    super.dispose();
  }

  void _showErrorToast(BuildContext context, String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<void> _login(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      await authViewModel.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (authViewModel.errorMessage != null) {
        _showErrorToast(context, authViewModel.errorMessage!);
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LoginForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        showPassword: _showPassword,
                      ),
                      const Spacer(),
                      if (authViewModel.isLoading)
                        const Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 42,
                            )
                          ],
                        ),
                      if (!authViewModel.isLoading)
                        AuthButtons(
                          onSignUpPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          onLoginPressed: () => _login(context),
                          isLoginScreen: true,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

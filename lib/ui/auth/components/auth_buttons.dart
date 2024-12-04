import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:password_project/ui/auth/auth_view_model.dart';
import 'package:password_project/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

class AuthButtons extends StatelessWidget {
  final VoidCallback onSignUpPressed;
  final VoidCallback onLoginPressed;
  final bool isLoginScreen;

  const AuthButtons({
    super.key,
    required this.onSignUpPressed,
    required this.onLoginPressed,
    this.isLoginScreen = false,
  });

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.currentUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          });
        }

        return Column(
          children: [
            Text(
              isLoginScreen
                  ? 'Don\'t have an account?'
                  : 'Already have an account?',
              style: const TextStyle(fontSize: 14),
            ),
            TextButton(
              onPressed: isLoginScreen ? onSignUpPressed : onLoginPressed,
              style: TextButton.styleFrom(padding: const EdgeInsets.all(8)),
              child: Text(
                isLoginScreen ? 'Sign up' : "Login",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: isLoginScreen ? onLoginPressed : onSignUpPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(isLoginScreen ? 'Login' : 'Sign up'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'or',
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await authViewModel.loginWithGoogle();

                if (authViewModel.errorMessage != null) {
                  _showErrorToast(context, authViewModel.errorMessage!);
                } else {
                  print('Login success');
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.google,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign up with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

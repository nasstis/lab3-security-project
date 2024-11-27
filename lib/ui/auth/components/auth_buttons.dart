import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  }
}

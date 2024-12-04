import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:password_project/ui/auth/auth_view_model.dart';
import 'package:password_project/ui/auth/components/auth_buttons.dart';
import 'package:password_project/ui/auth/components/sign_up_form.dart';
import 'package:password_project/ui/auth/login_screen.dart';
import 'package:password_project/ui/auth/slider_captcha/show_captcha.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ValueNotifier<bool> _showPassword = ValueNotifier(false);
  final ValueNotifier<bool> _showConfirmPassword = ValueNotifier(false);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _showPassword.dispose();
    _showConfirmPassword.dispose();
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

  Future<void> _signUp(BuildContext context) async {
    final captchaPassed = await showRecaptcha(context);

    if (!captchaPassed) {
      print("Captcha failed");
      return;
    }
    print("Captcha passed");
    if (context.mounted) {
      final authViewModel = context.read<AuthViewModel>();
      FocusScope.of(context).unfocus();

      if (_formKey.currentState!.validate()) {
        await authViewModel.registerUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text,
        );

        if (authViewModel.errorMessage != null) {
          _showErrorToast(context, authViewModel.errorMessage!);
        } else {
          authViewModel.sendActivationLink(_emailController.text.trim()).then(
            (_) {
              if (authViewModel.errorMessage == null) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'A confirmation email has been sent to you. Confirm your email address to complete the registration'),
                    ),
                  );
                });
              }
            },
          );
        }
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
                        'Sign up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SignUpForm(
                        formKey: _formKey,
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        showPassword: _showPassword,
                        showConfirmPassword: _showConfirmPassword,
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
                          onSignUpPressed: () => _signUp(context),
                          onLoginPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ));
                          },
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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:password_project/ui/auth/auth_view_model.dart';
import 'package:password_project/utils/helpers/confirm_password_validator.dart';
import 'package:password_project/utils/helpers/password_validator.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ValueNotifier<bool> _showPassword = ValueNotifier(false);
  final ValueNotifier<bool> _showConfirmPassword = ValueNotifier(false);
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  String? token;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showToast(BuildContext context, String message, Color color) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    token = ModalRoute.of(context)?.settings.arguments as String?;

    return AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
            ),
            body: SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Enter new password',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPasswordFormField(
                                      controller: _passwordController,
                                      hintText: 'Enter password',
                                      showPasswordNotifier: _showPassword,
                                      error: _passwordError,
                                      validator: (value) =>
                                          passwordValidator(value),
                                      onValidationError: (error) => setState(
                                          () => _passwordError = error),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPasswordFormField(
                                      controller: _confirmPasswordController,
                                      hintText: 'Confirm password',
                                      showPasswordNotifier:
                                          _showConfirmPassword,
                                      error: _confirmPasswordError,
                                      validator: (value) =>
                                          confirmPasswordValidator(
                                              value, _passwordController.text),
                                      onValidationError: (error) => setState(
                                          () => _confirmPasswordError = error),
                                    ),
                                  ],
                                ),
                              ),
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if (_formKey.currentState!.validate()) {
                                      if (token != null) {
                                        await authViewModel.resetPassword(
                                            token!,
                                            _passwordController.text.trim());
                                        if (context.mounted) {
                                          if (authViewModel.errorMessage !=
                                              null) {
                                            _showToast(
                                                context,
                                                authViewModel.errorMessage!,
                                                Colors.red);
                                          } else {
                                            _showToast(
                                                context,
                                                'Your password successfully reseted!',
                                                Colors.black);
                                            Navigator.pushReplacementNamed(
                                                context, '/');
                                          }
                                        }
                                      }
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text('Reset Password'),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String hintText,
    required ValueNotifier<bool> showPasswordNotifier,
    required bool error,
    required FormFieldValidator<String> validator,
    required void Function(bool) onValidationError,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: showPasswordNotifier,
      builder: (_, showPassword, __) {
        return TextFormField(
          controller: controller,
          obscureText: !showPassword,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                    onTap: () => showPasswordNotifier.value = !showPassword,
                    child: Icon(showPassword
                        ? Icons.visibility_off
                        : Icons.visibility)),
                if (error)
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.error)),
              ],
            ),
          ),
          validator: (value) {
            final validationMessage = validator(value);
            onValidationError(validationMessage != null);
            return validationMessage;
          },
        );
      },
    );
  }
}

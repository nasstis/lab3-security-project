import 'package:flutter/material.dart';
import 'package:password_project/utils/helpers/email_validator.dart';
import 'package:password_project/utils/helpers/password_validator.dart';

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueNotifier<bool> showPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.showPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _emailError = false;
  bool _passwordError = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextFormField(
            controller: widget.emailController,
            hintText: 'Enter email',
            error: _emailError,
            validator: (value) => emailValidator(value),
            onValidationError: (error) => setState(() => _emailError = error),
          ),
          const SizedBox(height: 16),
          _buildPasswordFormField(
            controller: widget.passwordController,
            hintText: 'Enter password',
            showPasswordNotifier: widget.showPassword,
            error: _passwordError,
            validator: (value) => passwordValidator(value),
            onValidationError: (error) =>
                setState(() => _passwordError = error),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                ),
                child: const Text(
                  'Forgot Password?',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required bool error,
    required FormFieldValidator<String> validator,
    required void Function(bool) onValidationError,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: error ? const Icon(Icons.error) : null,
      ),
      validator: (value) {
        final validationMessage = validator(value);
        onValidationError(validationMessage != null);
        return validationMessage;
      },
    );
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

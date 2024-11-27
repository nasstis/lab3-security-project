import 'package:flutter/material.dart';
import 'package:password_project/utils/helpers/confirm_password_validator.dart';
import 'package:password_project/utils/helpers/email_validator.dart';
import 'package:password_project/utils/helpers/name_validator.dart';
import 'package:password_project/utils/helpers/password_validator.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> showPassword;
  final ValueNotifier<bool> showConfirmPassword;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showPassword,
    required this.showConfirmPassword,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _buildTextFormField(
            controller: widget.nameController,
            hintText: 'Enter your name',
            error: _nameError,
            validator: (value) => nameValidator(value),
            onValidationError: (error) => setState(() => _nameError = error),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildPasswordFormField(
            controller: widget.confirmPasswordController,
            hintText: 'Confirm password',
            showPasswordNotifier: widget.showConfirmPassword,
            error: _confirmPasswordError,
            validator: (value) =>
                confirmPasswordValidator(value, widget.passwordController.text),
            onValidationError: (error) =>
                setState(() => _confirmPasswordError = error),
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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:password_project/utils/helpers/email_validator.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  bool _emailError = false;

  @override
  void dispose() {
    _emailController.dispose();
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
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Enter your email address and we will send you a link to reset your password',
                                textAlign: TextAlign.center,
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
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'Enter email',
                                        suffixIcon: _emailError
                                            ? const Icon(Icons.error)
                                            : null,
                                      ),
                                      validator: (value) {
                                        final String? validateMessage =
                                            emailValidator(value);
                                        if (validateMessage != null) {
                                          setState(() {
                                            _emailError = true;
                                          });
                                        } else {
                                          setState(() {
                                            _emailError = false;
                                          });
                                        }
                                        return validateMessage;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    if (_formKey.currentState!.validate()) {}
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text('Send Link'),
                                  ),
                                )),
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
}

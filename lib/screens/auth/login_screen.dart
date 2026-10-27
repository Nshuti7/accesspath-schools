import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/auth_form_layout.dart';
import '../../widgets/form_error_text.dart';
import '../../widgets/submit_button.dart';
import '../../validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // The router moves to the dashboard on success, so nothing else to do here.
    await context.read<AuthProvider>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _goToSignUp() {
    context.read<AuthProvider>().clearError();
    context.go(AppRoutes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthFormLayout(
      heading: AppStrings.logIn,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.password,
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: validateRequired,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (auth.errorMessage != null) ...[
          FormErrorText(auth.errorMessage!),
          const SizedBox(height: 16),
        ],
        SubmitButton(
          label: AppStrings.logIn,
          isBusy: auth.isBusy,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: auth.isBusy ? null : _goToSignUp,
          child: const Text(AppStrings.noAccount),
        ),
      ],
    );
  }
}

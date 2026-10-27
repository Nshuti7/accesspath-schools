import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/auth_form_layout.dart';
import '../../widgets/district_field.dart';
import '../../widgets/form_error_text.dart';
import '../../widgets/school_type_field.dart';
import '../../widgets/submit_button.dart';
import '../../validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _district = '';
  String _schoolType = '';

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().signUp(
      name: _nameController.text.trim(),
      schoolName: _schoolController.text.trim(),
      district: _district,
      schoolType: _schoolType,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _goToLogin() {
    context.read<AuthProvider>().clearError();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthFormLayout(
      heading: AppStrings.signUp,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.yourName,
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.schoolName,
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.organizationName],
                  textInputAction: TextInputAction.next,
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                DistrictField(onChanged: (value) => _district = value),
                const SizedBox(height: 16),
                SchoolTypeField(onChanged: (value) => _schoolType = value),
                const SizedBox(height: 16),
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
                    helperText: 'At least 6 characters',
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: validateNewPassword,
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
          label: AppStrings.signUp,
          isBusy: auth.isBusy,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: auth.isBusy ? null : _goToLogin,
          child: const Text(AppStrings.haveAccount),
        ),
      ],
    );
  }
}

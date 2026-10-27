import '../../strings.dart';

String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
  return null;
}

String? validateEmail(String? value) {
  final required = validateRequired(value);
  if (required != null) return required;
  // Only a light check here; Firebase does the real validation.
  if (!value!.contains('@') || !value.contains('.')) {
    return AppStrings.errorInvalidEmail;
  }
  return null;
}

String? validateNewPassword(String? value) {
  final required = validateRequired(value);
  if (required != null) return required;
  // Firebase rejects passwords under 6 characters; catch it before the request.
  if (value!.length < 6) return AppStrings.errorWeakPassword;
  return null;
}

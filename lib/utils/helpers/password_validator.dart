String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'The field cannot be empty';
  }
  if (value.length < 8 || value.length > 16) {
    return 'Password must be between 8 and 16 characters long';
  }
  if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
    return 'Password must contain at least one digit';
  }
  if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
    return 'Password must contain at least one special character (@, \$, !, %, *, ?, &)';
  }
  return null;
}

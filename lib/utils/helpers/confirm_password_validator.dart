String? confirmPasswordValidator(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'The field cannot be empty';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}

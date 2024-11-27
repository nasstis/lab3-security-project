String? nameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'The field cannot be empty';
  }
  return null;
}

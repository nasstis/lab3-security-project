String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'The field cannot be empty';
  }
  if (!value.contains('@')) {
    return 'The email must contain the "@" symbol';
  }
  if (!value.contains('.')) {
    return 'The email must contain a domain (e.g., ".com")';
  }
  if (!RegExp(".+@.+\\..+").hasMatch(value)) {
    return 'The email format is incorrect';
  }
  return null;
}

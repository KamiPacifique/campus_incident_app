import 'constants.dart';

class Validators {
  static String? aluEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) return 'Enter a valid email address';
    final domain = email.split('@').last;
    if (!allowedEmailDomains.contains(domain)) {
      return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    }
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 3) return 'Enter your full name';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include at least one letter and one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? title(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Add a short title';
    if (v.length < 5) return 'Title must be at least 5 characters';
    if (v.length > 80) return 'Title must be 80 characters or fewer';
    return null;
  }

  static String? description(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Describe what happened';
    if (v.length < 20) return 'Add a bit more detail (at least 20 characters)';
    if (v.length > 500) return 'Description must be 500 characters or fewer';
    return null;
  }

  static String? location(String? value) =>
      (value == null || value.isEmpty) ? 'Choose where the issue is' : null;
}

import 'package:email_validator/email_validator.dart';

class AuthValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    String email = value.trim();

    if (email.contains(" ")) {
      return "Email cannot contain spaces";
    }

    if (RegExp(r'^[0-9]').hasMatch(email)) {
      return "Email cannot start with a digit";
    }

    if (!RegExp(r'^[a-zA-Z0-9._%\-@]+$').hasMatch(email)) {
      return "Email contains invalid characters";
    }

    if (email.contains("..")) {
      return "Email cannot contain consecutive dots";
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return "Enter a valid email format";
    }

    if (!EmailValidator.validate(email, true)) {
      return "Enter a valid email address";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.length < 6) {
      return 'Username must be at least 6 characters';
    }
    return null;
  }
}

class FormValidators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    final username = value.toLowerCase();
    if (username.length < 3) return 'Username must be at least 3 characters';
    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }
    final usernameRegex = RegExp(r'^[a-z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Phone number validation (optional field)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10) return 'Enter a valid phone number';
    return null;
  }

  // Password strength calculation
  static PasswordStrength getPasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;

    if (strength >= 3) return PasswordStrength.strong;
    if (strength >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
}

enum PasswordStrength { weak, medium, strong }

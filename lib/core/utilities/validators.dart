/// Form checks shared by every form in the app, so the same input gets the
/// same error message everywhere. The real rules will be enforced by
/// Firebase later; these just catch obvious mistakes early.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Malaysian mobile numbers: 01X followed by 7 or 8 digits.
  static final RegExp _phonePattern = RegExp(r'^01\d{8,9}$');

  static bool _isEmail(String value) => _emailPattern.hasMatch(value.trim());

  /// Spaces and dashes are ignored, so "012-345 6789" is fine.
  static bool _isPhone(String value) {
    return _phonePattern.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''));
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    if (!_isEmail(text)) return 'Please enter a valid email';
    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your phone number';
    if (!_isPhone(text)) return 'Please enter a valid Malaysian number';
    return null;
  }

  /// Login accepts either an email or a phone number.
  static String? emailOrPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email or phone number';
    if (!_isEmail(text) && !_isPhone(text)) {
      return 'Please enter a valid email or phone number';
    }
    return null;
  }

  /// For creating a password (sign-up, reset).
  static String? newPassword(String? value) {
    if ((value ?? '').length < 8) return 'Use at least 8 characters';
    return null;
  }

  /// For signing in. Only checks it is not empty.
  static String? password(String? value) {
    if ((value ?? '').isEmpty) return 'Please enter your password';
    return null;
  }
}

class Validators {
  static bool validateEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  static bool isPasswordStrong(String value) {
    return value.length > 6;
  }

  static double applyDiscount(double price, double percent) {
    final clamped = percent.clamp(0, 100);
    return price * (1 - (clamped / 100));
  }

  static bool isValidRange(int number) {
    return number >= 1 && number <= 10;
  }

  static String toUppercase(String text) {
    return text.toUpperCase();
  }
}
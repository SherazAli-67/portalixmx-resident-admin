class FormatingHelper {
  static const double maxPaymentAmount = 1000000;

  static String formatPhoneNumber(String number) {
    if (number.length == 10) {
      return '(${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}';
    }
    return number;
  }

  static String normalizeAmountInput(String raw) {
    return raw.trim().replaceAll(',', '');
  }

  static double? tryParseAmount(String raw) {
    final cleaned = normalizeAmountInput(raw);
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  static String? validatePaymentAmount(String raw) {
    final cleaned = normalizeAmountInput(raw);
    if (cleaned.isEmpty) return 'empty';
    if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      if (parts.length != 2 || parts[1].length > 2) return 'decimals';
    }
    final value = double.tryParse(cleaned);
    if (value == null) return 'invalid';
    if (value <= 0) return 'zero';
    if (value > maxPaymentAmount) return 'max';
    return null;
  }

  static String formatCurrency(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final chars = parts[0].split('');
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return '\$${buffer.toString()}.${parts[1]}';
  }

  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static bool isValidPhoneNumber(String phone) {
    return digitsOnly(phone).length == 10;
  }
}

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? validateAppointmentDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Appointment date is required';
    }
    // debugPrint("Value is: $value");
    final trimmed = value.trim();
    final parts = trimmed.split(',');
    final dateParts = parts.first.split(' ');
    final day = int.tryParse(dateParts[0]);

    if (day! < 1 || day > 31) {
      return 'Day must be between 1 and 31';
    }
    return null;
  }
}
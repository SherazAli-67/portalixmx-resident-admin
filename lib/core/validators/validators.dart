import 'package:portalixmx_resident_admin/core/helpers/formating_helper.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';

class Validators {
  static String? Function(String?) validateEmail(AppLocalizations localization) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return localization.enterEmailAddress;
      }
      if (!FormatingHelper.isValidEmail(value)) {
        return localization.pleaseEnterValidEmail;
      }
      return null;
    };
  }

  static String? Function(String?) validatePassword(
    AppLocalizations localization, {
    bool requireMinLength = true,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return localization.passwordRequired;
      }
      if (requireMinLength && value.trim().length < 8) {
        return localization.passwordMinLength;
      }
      return null;
    };
  }

  static String? Function(String?) validateFullName(AppLocalizations localization) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return localization.pleaseEnterName;
      }
      if (value.trim().length < 2) {
        return localization.fullNameMinLength;
      }
      return null;
    };
  }

  static String? Function(String?) validateAppointmentDate(AppLocalizations localization) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return localization.appointmentDateRequired;
      }
      final trimmed = value.trim();
      final parts = trimmed.split(',');
      final dateParts = parts.first.split(' ');
      final day = int.tryParse(dateParts[0]);

      if (day == null || day < 1 || day > 31) {
        return localization.dayMustBeBetween1And31;
      }
      return null;
    };
  }
}

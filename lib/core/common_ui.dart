import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';

class CommonUI {
  static void showSnackBarMessage(
      BuildContext context, {
        String? title,
        String? message,
        bool isError = false,
        bool isSuccess = false}) {
    Color? bgColor = isError ? Colors.red : isSuccess ? Colors.green : null;
    Color? textIconColor = isError || isSuccess ? Colors.white : null;

    ScaffoldMessenger.of(context,).showSnackBar(SnackBar(
        backgroundColor: bgColor,
        content: Column(
            crossAxisAlignment: .start,
            children: [
              if(title != null)
                Text(title, style: AppTextStyles.regularTextStyle.copyWith(color: textIconColor, fontWeight: .bold),),

              if(message != null)
                Text(message, style: AppTextStyles.regularTextStyle.copyWith(color: textIconColor),)
            ])));
  }

  static Future<bool> confirmDelete(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final localization = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? localization.delete),
        content: Text(message ?? localization.deleteConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(localization.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              localization.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}

import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';

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
}

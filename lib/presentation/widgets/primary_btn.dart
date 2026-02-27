import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import 'loading_widget.dart';

class PrimaryBtn extends StatelessWidget{
  final VoidCallback onTap;
  final String btnText;
  final Color bgColor;
  final bool isLoading;
  final Color? textColor;
  const PrimaryBtn({super.key, required this.onTap, required this.btnText, this.bgColor = AppColors.btnColorDark, this.textColor, this.isLoading = false});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: bgColor
        ),
        onPressed: onTap, child: isLoading ? LoadingWidget() : Text(btnText,style: AppTextStyles.btnTextStyle.copyWith(color: textColor),));
  }

}
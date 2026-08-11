import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class PopupMenuItemWidget extends StatelessWidget {
  const PopupMenuItemWidget({
    super.key,
    required this.icon,
    required this.title
  });

  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Icon(icon, size: 20, color: AppColors.greyColor2),
        Text(title, style: AppTextStyles.tileTitleTextStyle),
      ],
    );
  }
}
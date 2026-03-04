import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class FilterTabWidget extends StatelessWidget{
  const FilterTabWidget({super.key, required this.isSelected, required this.onTap, required this.title});
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: isSelected ? ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor): null,
        onPressed: onTap,
        child: Text(title, style: AppTextStyles.tabsTextStyle.copyWith(color: isSelected ? Colors.white : AppColors.primaryColor),));
  }
}
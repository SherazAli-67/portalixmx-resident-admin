import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';


class VisitorInfoItemWidget extends StatelessWidget{
  final String _title;
  final String _subtitle;
  final bool _showDivider;

  const VisitorInfoItemWidget({super.key, required String title, required String subTitle, bool showDivider = false}): _title = title, _subtitle = subTitle, _showDivider = showDivider;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_title, style: AppTextStyles.visitorDetailTitleTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400),),
        Text(_subtitle, style: AppTextStyles.visitorDetailSubtitleTextStyle.copyWith(fontSize: 14),),
        const SizedBox(height: 20,),
        if(_showDivider)
          Divider(color: AppColors.dividerColor,)
      ],
    );
  }

}
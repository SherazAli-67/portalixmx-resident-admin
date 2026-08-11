import 'package:flutter/material.dart';
import '../../core/models/complaints_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class ComplaintStatusWidget extends StatelessWidget {
  const ComplaintStatusWidget({
    super.key,
    required this.status
  });
  final ComplaintStatus status;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: getColorByStatus(status).withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Text(
       status.name.toUpperCase(),
        style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: getColorByStatus(status)),
      ),
    );
  }

  Color getColorByStatus(ComplaintStatus status) {
    switch(status){
      case .pending:
        return AppColors.btnColor;
      case .inProgress:
        return AppColors.primaryColor;
      case .resolved:
        return Colors.green;
      case .rejected:
        return Colors.red;
    }
  }
}
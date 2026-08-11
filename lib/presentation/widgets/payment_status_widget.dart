import 'package:flutter/material.dart';
import '../../core/models/payment_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class PaymentStatusWidget extends StatelessWidget {
  const PaymentStatusWidget({
    super.key,
    required this.status
  });
  final PaymentStatus status;
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

  Color getColorByStatus(PaymentStatus status) {
    switch(status){
      case .pending:
        return AppColors.btnColor;
      case .submitted:
        return AppColors.primaryColor;
      case .received:
        return Colors.green;
    }
  }
}
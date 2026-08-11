import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/bg_gradient_screen.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';

class ResidentPaymentHistoryPage extends StatelessWidget{
  const ResidentPaymentHistoryPage({super.key, required this.userID});
  final String userID;

  String _initials(String title) {
    final words = title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: .only(top: 65),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                BackButton(color: Colors.white,),
                Text(localizations.paymentHistory, style: AppTextStyles.regularTextStyle,),
                const SizedBox(width: 40,),
              ],
            ),
          ),
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: .zero,
              shape: RoundedRectangleBorder(
                  borderRadius: .only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
              ),
              child: Padding(
                padding: const .only(top: 36.0, left: 18, right: 18),
                child: FutureBuilder(
                  future: PaymentsService.instance.getUserPaymentHistory(userID: userID),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == .waiting) {
                      return LoadingWidget(color: AppColors.primaryColor);
                    }
                    final payments = snapshot.data ?? <PaymentModel>[];
                    if (payments.isEmpty) {
                      return Center(
                        child: Text("No payment requests found", style: AppTextStyles.regularTextStyle),
                      );
                    }
                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (ctx, index) {
                        final payment = payments[index];
                        return Container(
                          margin: .only(bottom: 10),
                          padding: .symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: .circular(15),
                            border: .all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            spacing: 17,
                            crossAxisAlignment: .start,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                child: Center(
                                  child: Text(
                                    _initials(payment.paymentForTitle),
                                    style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  spacing: 2,
                                  crossAxisAlignment: .start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: .spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            payment.paymentForTitle,
                                            style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),
                                          ),
                                        ),
                                        Text(
                                          "\$${payment.amount}",
                                          style: TextStyle(fontSize: 12, fontWeight: .w700, color: AppColors.btnColor),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      DateTimeFormatHelpers.formatDateTime(payment.dateTime),
                                      style: TextStyle(fontSize: 10, fontWeight: .w500, color: AppColors.serviceSubTitleGreyColor),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      payment.description,
                                      style: TextStyle(fontSize: 10, fontWeight: .w500, color: AppColors.serviceSubTitleGreyColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

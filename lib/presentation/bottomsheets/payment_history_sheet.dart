import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/datetime_format_helpers.dart';

class PaymentHistorySheet extends StatelessWidget{
  const PaymentHistorySheet({super.key, required this.resident, this.scrollController, this.physics});
  final UserModel resident;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 25),
        child: Column(
          children: [
            Text(localization.paymentHistory, style: AppTextStyles.bottomSheetHeadingTextStyle,),
            Expanded(
              child: FutureBuilder(future: PaymentsService.instance.getUserPaymentHistory(userID: resident.userID), builder: (ctx, snapshot){
                if(snapshot.connectionState == .waiting) LoadingWidget(color: AppColors.primaryColor,);
                List<PaymentModel> payments = snapshot.data ?? [];
                return ListView.separated(
                    controller: scrollController,
                    physics: physics,
                    itemBuilder: (_, index){
                      PaymentModel payment = payments[index];
                      List<String> words = payment.paymentForTitle.split(' ');
                      return Container(
                          margin: .only(bottom: 10),
                          padding: .symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: .circular(15), border: .all(color: AppColors.borderColor)),
                          child: Row(
                            spacing: 17,
                            crossAxisAlignment: .start,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                child: Center(child: Text("${words[0][0]}${words[1][0]}", style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),),
                              ),
                              Expanded(
                                child: Column(
                                  spacing: 2,
                                  crossAxisAlignment: .start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: .spaceBetween,
                                      children: [
                                        Text(payment.paymentForTitle, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),
                                        Text("\$${payment.amount}", style: TextStyle(fontSize: 12, fontWeight: .w700, color: AppColors.btnColor),)
                                      ],
                                    ),
                                    Text(DateTimeFormatHelpers.formatDateTime(payment.dateTime), style: TextStyle(fontSize: 10, fontWeight: .w500, color: AppColors.serviceSubTitleGreyColor),),
                                    const SizedBox(height: 3,),
                                    Text(payment.description, style: TextStyle(fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.serviceSubTitleGreyColor),),                                  ],
                                ),
                              )
                            ],
                          )
                      );
                    }, separatorBuilder: (_, index) => const SizedBox(height: 10,), itemCount: payments.length);
              },
            ))
          ],
        ),
      ),
    );
  }
}
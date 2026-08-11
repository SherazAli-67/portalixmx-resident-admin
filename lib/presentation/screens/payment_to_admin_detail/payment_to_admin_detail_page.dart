import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/submit_payment_to_admin_bottomsheet.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/main_menu.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_constants.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/vistor_info_item_widget.dart';
class PaymentToAdminDetailPage extends StatelessWidget{
  const PaymentToAdminDetailPage({super.key, required this.payment});
  final PaymentModel payment;
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BgGradientScreen(child: Column(
      spacing: 20,
      children: [
        Padding(padding: .only(top: 65),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              BackButton(color: Colors.white,),
              Text(localizations.paymentDetail, style: AppTextStyles.regularTextStyle,),
              const SizedBox(width: 40,)
            ],
          ),
        ),

        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
            ),
            child: Padding(
                padding: const .only(top: 36.0, left: 18, right: 18),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 10,
                  children: [
                    Text(localizations.paymentDetail, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
                    Expanded(
                      child: Padding(
                        padding: const .only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              spacing: 20,
                              children: [
                                Expanded(
                                  child:VisitorInfoItemWidget(title: localizations.paymentFor, subTitle: payment.paymentForTitle,),

                                ),
                                Expanded(
                                    child: VisitorInfoItemWidget(
                                      title: localizations.amount, subTitle: '${payment.amount}')
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(child: VisitorInfoItemWidget(title: localizations.date, subTitle: DateTimeFormatHelpers.formatDateTime(payment.dateTime), showDivider: payment.paymentStatus ==.received ),),
                                Expanded(
                                    child: VisitorInfoItemWidget(
                                      title: localizations.status, subTitle: payment.paymentStatus.name.toUpperCase(),)
                                ),
                              ],
                            ),

                            Expanded(child: payment.paymentStatus == .pending ? _buildSubmitPaymentBtn(localizations, context) : payment.paymentStatus == .pending ? _buildSubmitPaymentBtn(localizations, context) : _buildReceiptImage(localizations)),

                            /*Expanded(child: GridView.builder(
                                itemCount: 2,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,   mainAxisSpacing: 10, crossAxisSpacing: 10), itemBuilder: (ctx, index){
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(imageUrl: ImageUrlHelper.getImageUrl(payment.images[index]), height: 75, fit: BoxFit.cover,),
                              );
                            }))*/
                          ],
                        ),
                      ),
                    )
                  ],
                )
            ),
          ),
        )
      ],
    ),);
  }

  _buildSubmitPaymentBtn(AppLocalizations localization, BuildContext context) {
    return Padding(
      padding: const.only(bottom: 20.0),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: .infinity,
            child: PrimaryBtn(onTap: ()async{
             final result = await BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: SubmitPaymentToAdminBottomSheet(payment: payment));
             if(result != null){
               //Upload receipt and update paymentStatus to submitted
               _updatePaymentStatus(context, result['receipt']);
             }
            }, btnText: localization.submit),
          ),
        ],
      ),
    );
  }

  _buildReceiptImage(AppLocalizations localizations,) {
    return Column(
      spacing: 10,
      crossAxisAlignment: .start,
      children: [
        Text(localizations.receipt, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor)),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(imageUrl: AppConstants.dummyImageUrl, fit: BoxFit.cover,),
        )
      ],
    );
  }

  void _updatePaymentStatus(BuildContext context, XFile receiptImage)async {
    final updatedPayment = payment.copyWith(receipt: receiptImage.path, paymentStatus: .submitted);
    Navigator.pop(context, updatedPayment);
  }
}
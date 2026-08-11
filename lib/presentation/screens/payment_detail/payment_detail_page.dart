import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/payment_history_sheet.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/main_menu.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/payment_status_widget.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_constants.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/popup_menu_item_widget.dart';
import '../../widgets/vistor_info_item_widget.dart';

enum _PaymentDetailMenuAction {
  markAsReceived,
  userPaymentHistory,
}

class PaymentDetailPage extends StatelessWidget{
  const PaymentDetailPage({super.key, required this.payment});
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
              PopupMenuButton<_PaymentDetailMenuAction>(
                elevation: 0,
                color: Colors.white,
                position: PopupMenuPosition.under,
                padding: .zero,
                iconColor: Colors.white,
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) {
                  switch (action) {
                    case .markAsReceived:
                      Navigator.pop(context, PaymentStatus.received);
                    case .userPaymentHistory:
                      context.push(NamedRoutes.residentPaymentHistory.routeName, extra: payment.paymentByUID);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: .userPaymentHistory,
                    child: PopupMenuItemWidget(
                        title: localizations.paymentHistory,
                        icon: Icons.history),
                  ),
                  if (payment.paymentStatus == .pending)
                    PopupMenuItem(
                      value: .markAsReceived,
                      child: PopupMenuItemWidget(
                          title: localizations.markAsReceived,
                          icon: Icons.check_box_outlined),
                    ),
                ],
              ),
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

                    FutureBuilder(
                      future: UserService.instance.getUserByID(userID: payment.paymentByUID),
                      builder: (ctx, snapshot) {
                        final paymentUser = snapshot.data;
                        return Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(localizations.aboutResident, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
                            Padding(
                              padding: const .only(top: 10.0),
                              child: GestureDetector(
                                onTap: (){
                                  BottomSheetHelper.showDraggableListBottomSheet(scaffoldKey: scaffoldKey, contentBuilder: (controller, physics)=> PaymentHistorySheet(resident: paymentUser!, scrollController: controller, physics: physics));
                                },
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: paymentUser?.profileImg ?? AppConstants.dummyImageUrl,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(paymentUser?.userName ?? 'Unknown', style: AppTextStyles.tileTitleTextStyle),
                                          Text(paymentUser?.phoneNum ?? 'Unknown', style: AppTextStyles.tileTitleTextStyle),
                                        ],
                                      ),
                                    ),
                                    PaymentStatusWidget(status: payment.paymentStatus)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const .only(top: 15.0),
                              child: VisitorInfoItemWidget(title: localizations.email, subTitle: paymentUser?.email ?? 'Unknown'),
                            ),
                            VisitorInfoItemWidget(title: localizations.houseNumber, subTitle: '#${paymentUser?.houseNumber ?? '706'}', showDivider: true,)
                          ],
                        );
                      },
                    ),
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
                                      title: localizations.status, subTitle: payment.paymentStatus.name.toUpperCase(),)
                                ),
                              ],
                            ),
                            VisitorInfoItemWidget(title: localizations.date, subTitle: DateTimeFormatHelpers.formatDateTime(payment.dateTime), showDivider: true ),
                            Column(
                              spacing: 10,
                              crossAxisAlignment: .start,
                              children: [
                                Text(localizations.receipt, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor)),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(imageUrl: AppConstants.dummyImageUrl, fit: BoxFit.cover,),
                                )
                              ],
                            )
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
}
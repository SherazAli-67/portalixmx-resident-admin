import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/resident_payment_receipt_sheet.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/payment_status_widget.dart';
import 'package:portalixmx_resident_admin/providers/payments_provider/payment_detail_provider.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/vistor_info_item_widget.dart';

class PaymentDetailPage extends StatelessWidget{
  const PaymentDetailPage({super.key, required this.payment});
  final PaymentModel payment;
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => PaymentDetailProvider(payment: payment),
      builder: (ctx, _) {
        return BgGradientScreen(child: Column(
          spacing: 20,
          children: [
            Padding(padding: .only(top: 65),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  BackButton(color: Colors.white,),
                  Text(localizations.paymentDetail, style: AppTextStyles.regularTextStyle,),
                  const SizedBox(width: 40,),
                ],
              ),
            ),

            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: .only(topLeft: .circular(30), topRight: .circular(30))
                ),
                child: Padding(
                    padding: const .only(top: 36.0, left: 18, right: 18),
                    child: Consumer<PaymentDetailProvider>(
                      builder: (ctx, provider, _) {
                        return Column(
                          crossAxisAlignment: .start,
                          spacing: 10,
                          children: [
                            Text(localizations.paymentDetail, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
                            Row(
                              spacing: 20,
                              children: [
                                Expanded(
                                  child: VisitorInfoItemWidget(title: localizations.paymentFor, subTitle: payment.paymentForTitle,),
                                ),
                                Expanded(
                                    child: VisitorInfoItemWidget(
                                      title: localizations.amount, subTitle: '\$${payment.amount}',)
                                ),
                              ],
                            ),
                            VisitorInfoItemWidget(title: localizations.description, subTitle: payment.description),
                            VisitorInfoItemWidget(title: localizations.date, subTitle: DateTimeFormatHelpers.formatDateTime(payment.dateTime), showDivider: true ),
                            Text(localizations.residents, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
                            Expanded(
                              child: provider.loading
                                  ? LoadingWidget(color: AppColors.primaryColor)
                                  : provider.residents.isEmpty
                                      ? Center(child: Text(localizations.emptyResidentsMsg, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.darkGreyColor),))
                                      : ListView.separated(
                                          itemCount: provider.residents.length,
                                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                                          itemBuilder: (ctx, index) {
                                            final resident = provider.residents[index];
                                            return _ResidentPaymentRow(
                                              resident: resident,
                                              status: provider.statusFor(resident.userID),
                                              onTap: () => _onResidentTap(context, provider: provider, resident: resident),
                                              onHistoryTap: () => context.push(NamedRoutes.residentPaymentHistory.routeName, extra: resident.userID),
                                            );
                                          },
                                        ),
                            ),
                          ],
                        );
                      },
                    )
                ),
              ),
            )
          ],
        ),);
      },
    );
  }

  void _onResidentTap(BuildContext context, {required PaymentDetailProvider provider, required UserModel resident}) async {
    final status = provider.statusFor(resident.userID);
    if (status == .pending) return;
    final submission = provider.submissionFor(resident.userID);
    if (submission == null) return;
    final marked = await BottomSheetHelper.showAdjustableModalBottomSheet<bool>(
      context: context,
      initialChildSize: 0.7,
      child: ResidentPaymentReceiptSheet(
        payment: payment,
        resident: resident,
        submission: submission,
      ),
    );
    if (marked == true) {
      await provider.refreshSubmissions();
    }
  }
}

class _ResidentPaymentRow extends StatelessWidget {
  const _ResidentPaymentRow({
    required this.resident,
    required this.status,
    required this.onTap,
    required this.onHistoryTap,
  });

  final UserModel resident;
  final PaymentStatus status;
  final VoidCallback onTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: .circular(15), side: BorderSide(color: AppColors.borderColor2)),
      child: ListTile(
        onTap: onTap,
        contentPadding: .symmetric(horizontal: 10),
        leading: CircleAvatar(
          backgroundColor: AppColors.btnColor,
          child: const Center(
            child: Icon(Icons.person, color: Colors.white,),
          ),
        ),
        title: Text(resident.userName, style: AppTextStyles.tileTitleTextStyle,),
        subtitle: Text(
          resident.houseNumber != null ? '#${resident.houseNumber}' : resident.phoneNum ?? '',
          style: AppTextStyles.tileSubtitleTextStyle,
        ),
        trailing: Row(
          mainAxisSize: .min,
          children: [
            PaymentStatusWidget(status: status),
            IconButton(
              onPressed: onHistoryTap,
              icon: const Icon(Icons.history, size: 20),
              color: AppColors.greyColor2,
            ),
          ],
        ),
      ),
    );
  }
}

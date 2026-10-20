import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/submit_payment_to_admin_bottomsheet.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/main_menu.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/vistor_info_item_widget.dart';

class PaymentToAdminDetailPage extends StatefulWidget {
  const PaymentToAdminDetailPage({super.key, required this.payment});
  final PaymentModel payment;

  @override
  State<PaymentToAdminDetailPage> createState() => _PaymentToAdminDetailPageState();
}

class _PaymentToAdminDetailPageState extends State<PaymentToAdminDetailPage> {
  late PaymentModel payment;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    payment = widget.payment;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final receiptUrl = payment.receipt;
    final hasReceipt = receiptUrl != null && receiptUrl.startsWith('http');
    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const .only(top: 65),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                BackButton(color: Colors.white),
                Text(localizations.paymentDetail, style: AppTextStyles.regularTextStyle),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: .zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const .only(top: 36.0, left: 18, right: 18),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 10,
                  children: [
                    Text(
                      localizations.paymentDetail,
                      style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),
                    ),
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
                                  child: VisitorInfoItemWidget(
                                    title: localizations.paymentFor,
                                    subTitle: payment.paymentForTitle,
                                  ),
                                ),
                                Expanded(
                                  child: VisitorInfoItemWidget(
                                    title: localizations.amount,
                                    subTitle: '${payment.amount}',
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: VisitorInfoItemWidget(
                                    title: localizations.date,
                                    subTitle: DateTimeFormatHelpers.formatDateTime(payment.dateTime),
                                    showDivider: payment.paymentStatus == .received,
                                  ),
                                ),
                                Expanded(
                                  child: VisitorInfoItemWidget(
                                    title: localizations.status,
                                    subTitle: payment.paymentStatus.name.toUpperCase(),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: payment.paymentStatus == .pending
                                  ? _buildSubmitPaymentBtn(localizations)
                                  : hasReceipt
                                      ? _buildReceiptImage(localizations, receiptUrl)
                                      : Center(
                                          child: Text(
                                            'No receipt uploaded',
                                            style: AppTextStyles.tileSubtitleTextStyle,
                                          ),
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitPaymentBtn(AppLocalizations localization) {
    return Padding(
      padding: const .only(bottom: 20.0),
      child: Column(
        children: [
          const Spacer(),
          SafeArea(
            child: SizedBox(
              width: .infinity,
              child: PrimaryBtn(
                isLoading: _submitting,
                onTap: () async {
                  final result = await BottomSheetHelper.showDraggableBottomSheet(
                    scaffoldKey: scaffoldKey,
                    child: SubmitPaymentToAdminBottomSheet(payment: payment),
                  );
                  if (result == null || !mounted) return;
                  final receipt = result['receipt'] as XFile?;
                  if (receipt == null) return;
                  setState(() => _submitting = true);
                  try {
                    final url = await PaymentsService.instance.uploadAdminReceipt(
                      receipt: receipt,
                      paymentID: payment.paymentID,
                    );
                    final updated = payment.copyWith(receipt: url, paymentStatus: .submitted);
                    await PaymentsService.instance.submitPaymentToAdmin(payment: updated);
                    if (!mounted) return;
                    setState(() => payment = updated);
                    Navigator.pop(context, updated);
                  } catch (e) {
                    if (!mounted) return;
                    CommonUI.showSnackBarMessage(
                      context,
                      message: localization.failedToSubmitPaymentToAdmin,
                      isError: true,
                    );
                  } finally {
                    if (mounted) setState(() => _submitting = false);
                  }
                },
                btnText: localization.submit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImage(AppLocalizations localizations, String receiptUrl) {
    return Column(
      spacing: 10,
      crossAxisAlignment: .start,
      children: [
        Text(
          localizations.receipt,
          style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),
        ),
        ClipRRect(
          borderRadius: .circular(15),
          child: CachedNetworkImage(imageUrl: receiptUrl, fit: .cover),
        ),
      ],
    );
  }
}

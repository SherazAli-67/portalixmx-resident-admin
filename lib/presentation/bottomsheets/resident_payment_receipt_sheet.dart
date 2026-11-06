import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/payment_submitted_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/payment_status_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import '../../core/models/payment_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class ResidentPaymentReceiptSheet extends StatefulWidget {
  const ResidentPaymentReceiptSheet({
    super.key,
    required this.payment,
    required this.resident,
    required this.submission,
  });

  final PaymentModel payment;
  final UserModel resident;
  final PaymentSubmittedModel submission;

  @override
  State<ResidentPaymentReceiptSheet> createState() => _ResidentPaymentReceiptSheetState();
}

class _ResidentPaymentReceiptSheetState extends State<ResidentPaymentReceiptSheet> {
  bool _busy = false;

  PaymentStatus get _status => widget.submission.paymentStatus;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final receiptUrl = widget.submission.receipt;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const .symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 15,
              children: [
                Text(widget.resident.userName, style: AppTextStyles.bottomSheetHeadingTextStyle),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      widget.resident.houseNumber != null
                          ? '#${widget.resident.houseNumber}'
                          : widget.resident.phoneNum ?? '',
                      style: AppTextStyles.tileSubtitleTextStyle,
                    ),
                    PaymentStatusWidget(status: _status),
                  ],
                ),
                Text(localizations.receipt, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.primaryColor)),
                if (receiptUrl != null && receiptUrl.startsWith('http'))
                  ClipRRect(
                    borderRadius: .circular(15),
                    child: CachedNetworkImage(
                      imageUrl: receiptUrl,
                      height: 220,
                      width: .infinity,
                      fit: .cover,
                    ),
                  )
                else
                  Text(localizations.noReceiptAvailable, style: AppTextStyles.tileSubtitleTextStyle),
              ],
            ),
          ),
        ),
        if (_status == .submitted)
          SafeArea(
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                spacing: 10,
                children: [
                  SizedBox(
                    height: 50,
                    width: .infinity,
                    child: PrimaryBtn(
                      onTap: _onMarkReceivedTap,
                      btnText: localizations.markAsReceived,
                      isLoading: _busy,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: .infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _onRejectTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                      ),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                            )
                          : Text(
                              localizations.reject,
                              style: AppTextStyles.btnTextStyle.copyWith(color: Colors.red),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _onMarkReceivedTap() async {
    if (_busy) return;
    final localizations = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await PaymentsService.instance.markResidentPaymentReceived(
        payment: widget.payment,
        residentUid: widget.resident.userID,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      CommonUI.showToastMessage(
        localizations.failedToUpdatePaymentStatus,
        isError: true,
      );
      setState(() => _busy = false);
    }
  }

  void _onRejectTap() async {
    if (_busy) return;
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.reject),
        content: Text(localizations.confirmRejectReceipt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              localizations.reject,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await PaymentsService.instance.rejectResidentPaymentSubmission(
        payment: widget.payment,
        residentUid: widget.resident.userID,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      CommonUI.showToastMessage(
        localizations.failedToUpdatePaymentStatus,
        isError: true,
      );
      setState(() => _busy = false);
    }
  }
}

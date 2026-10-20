import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  PaymentStatus get _status =>
      widget.submission.approvedOnDate != null ? .received : .submitted;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final receiptUrl = widget.submission.receipt;
    return Padding(
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
            Text('No receipt available', style: AppTextStyles.tileSubtitleTextStyle),
          if (_status == .submitted)
            SafeArea(
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
                    child: PrimaryBtn(
                      onTap: _onRejectTap,
                      btnText: localizations.reject,
                      bgColor: Colors.red,
                      isLoading: _busy,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onMarkReceivedTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await PaymentsService.instance.markResidentPaymentReceived(
        paymentID: widget.payment.paymentID,
        residentUid: widget.resident.userID,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onRejectTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await PaymentsService.instance.rejectResidentPaymentSubmission(
        paymentID: widget.payment.paymentID,
        residentUid: widget.resident.userID,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import '../../../../core/models/access_request_model.dart';
import '../../../../core/res/app_icons.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/popup_menu_item_widget.dart';
import '../../../widgets/vistor_info_item_widget.dart';

class AccessSummaryPage extends StatelessWidget{
  const AccessSummaryPage({super.key, required this.access});
  final AccessRequestModel access;
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BgGradientScreen(child: Column(
      spacing: 20,
      children: [
        Padding(padding: EdgeInsets.only(top: 65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(color: Colors.white,),
              Text('${access.requestedAccessTitle} ${localizations.access}', style: AppTextStyles.regularTextStyle,),
              if(access.status == .pending)
                PopupMenuButton<RequestStatus>(
                  elevation: 0,
                  color: Colors.white,
                  position: PopupMenuPosition.under,
                  padding: .zero,
                  iconColor: Colors.white,
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (status) => Navigator.pop(context, status),
                  itemBuilder: (ctx) =>
                  [
                    PopupMenuItem(
                      value: RequestStatus.approved,
                      child: PopupMenuItemWidget(
                          title: localizations.approve,
                          icon: Icons.check_box_outlined),
                    ),
                    PopupMenuItem(
                      value: RequestStatus.rejected,
                      child: PopupMenuItemWidget(
                          title: localizations.reject,
                          icon: Icons.check_box_outlined),
                    ),
                  ],
                )
              else
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
                padding: const EdgeInsets.only(top: 36.0, left: 18, right: 18),
                child: Column(
                  spacing: 15,
                  children: [
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child: VisitorInfoItemWidget(
                            title: localizations.date, subTitle: DateTimeFormatHelpers.formatDateTime(access.createdAt),showDivider: true,),
                        ),
                        Expanded(
                            child: VisitorInfoItemWidget(
                              title: localizations.time, subTitle: DateTimeFormatHelpers.formatTime(access.requestedForTime),showDivider: true,)
                        ),
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child: VisitorInfoItemWidget(
                            title: localizations.requestedTime, subTitle: DateTimeFormatHelpers.formatDateTime(access.requestedForDate),),
                        ),
                        Expanded(
                            child: VisitorInfoItemWidget(
                              title: localizations.accessApprovedDate,
                              subTitle: access.status == .approved
                                  ? DateTimeFormatHelpers.formatDateTime(access.updatedAt)
                                  : '—',
                            ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    // Static QR kept until ZKBio QR integration (next milestone).
                    Text(localizations.qrCode, style: AppTextStyles.visitorDetailTitleTextStyle,),
                    Image.asset(AppIcons.icQRCode),
                    const Spacer(),
                  ],
                )
            ),
          ),
        )
      ],
    ),);
  }
}
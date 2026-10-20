import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/complaint_status_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/popup_menu_item_widget.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/complaints_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../../providers/maintenance_provider.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/date_range_filter_widget.dart';
import '../../../widgets/loading_widget.dart';

class MaintenanceMenu extends StatelessWidget {
  const MaintenanceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => MaintenanceProvider(),
      builder: (ctx, _) {
        return Consumer<MaintenanceProvider>(builder: (ctx, provider, _) {
          return BgGradientScreen(
            child: Stack(
              children: [
                Padding(
                  padding: const .symmetric(horizontal: 10.0),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: .start,
                    children: [
                      Align(
                          alignment: .center,
                          child: Padding(
                            padding: const .only(top: 35.0, bottom: 11),
                            child: Text(
                              localizations.maintenance, textAlign: .center,
                              style: AppTextStyles.headingTextStyle,),
                          )),
                      DateRangeFilterWidget(
                        dateFrom: provider.dateFrom,
                        dateTo: provider.dateTo,
                        onDateFromChanged: provider.onDateFromChanged,
                        onDateToChanged: provider.onDateToChanged,
                      ),
                      Expanded(
                        child: provider.loadingComplaints
                            ? LoadingWidget()
                            : RefreshIndicator(
                            onRefresh: () => provider.refreshComplaints(),
                            child: ListView.builder(
                                itemCount: provider.groupedComplaintItemCount,
                                itemBuilder: (ctx, index) {
                                  final groups = provider
                                      .complaintsGroupedByDate;
                                  int offset = 0;
                                  for (final group in groups) {
                                    final groupItemCount = 1 +
                                        group.complaints.length;
                                    if (index == offset) {
                                      return _buildDateHeader(group.date);
                                    }
                                    if (index > offset &&
                                        index < offset + groupItemCount) {
                                      final complaint = group.complaints[index -
                                          offset - 1];
                                      return _buildComplaintCard(
                                          context, provider, localizations,
                                          complaint);
                                    }
                                    offset += groupItemCount;
                                  }
                                  return const SizedBox.shrink();
                                })),
                      ),
                    ],
                  ),
                ),
                if(provider.updatingComplaint)
                  FullPageLoadingWidget(color: AppColors.primaryColor,)
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
          DateTimeFormatHelpers.formatDateTime(date),
          style: AppTextStyles.regularTextStyle
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context,
      MaintenanceProvider provider,
      AppLocalizations localizations,
      ComplaintModel complaint,) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => provider.onComplaintTap(context,complaint: complaint),
        child: Column(
          children: [
            FutureBuilder(
              future: provider.getUserByID(userID: complaint.complaintBy),
              builder: (ctx, snapshot) {
                final complaintByUser = snapshot.data;
                return Padding(
                  padding: const .all(8.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius
                            .circular(10)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (complaintByUser?.profileImg != null &&
                                  complaintByUser!.profileImg!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: complaintByUser.profileImg!,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(complaintByUser?.userName ?? 'Unknown',
                                style: AppTextStyles.tileTitleTextStyle),
                            Text(complaintByUser?.phoneNum ?? 'Unknown',
                                style: AppTextStyles.tileTitleTextStyle),
                          ],
                        ),
                      ),
                      if(complaint.status != .resolved)
                        PopupMenuButton<ComplaintStatus>(
                        elevation: 0,
                        color: Colors.white,
                        position: PopupMenuPosition.under,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (status) =>
                            provider.updateComplaintStatus(complaint: complaint
                                .copyWith(status: status)),
                        itemBuilder: (ctx) =>
                        [
                          PopupMenuItem(
                            value: ComplaintStatus.resolved,
                            child: PopupMenuItemWidget(
                                title: localizations.markAsResolved,
                                icon: Icons.check_box_outlined),
                          ),
                          PopupMenuItem(
                            value: ComplaintStatus.inProgress,
                            child: PopupMenuItemWidget(
                                title: localizations.markAsInProgress,
                                icon: Icons.hourglass_bottom_outlined),
                          ),
                          PopupMenuItem(
                            value: ComplaintStatus.rejected,
                            child: PopupMenuItemWidget(
                                title: localizations.reject, icon: Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: const .symmetric(horizontal: 15),
              title: Text(
                  complaint.complaint, style: AppTextStyles.tileTitleTextStyle),
              subtitle: Text(
                  DateTimeFormatHelpers.formatDateTime(complaint.createdAt),
                  style: AppTextStyles.tileSubtitleTextStyle),
              trailing: ComplaintStatusWidget(status:  complaint.status,),
            ),
          ],
        ),
      ),
    );
  }
}

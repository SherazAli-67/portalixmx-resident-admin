import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/complaint_status_widget.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';
import '../../../../core/helpers/image_url_helper.dart';
import '../../../../core/models/complaints_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/popup_menu_item_widget.dart';
import '../../../widgets/vistor_info_item_widget.dart';

class ComplaintSummaryPage extends StatelessWidget{
  const ComplaintSummaryPage({super.key, required this.complaint});
  final ComplaintModel complaint;
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
              Text(complaint.complaint, style: AppTextStyles.regularTextStyle,),
              if (complaint.status != .resolved && complaint.status != .rejected)
                PopupMenuButton<ComplaintStatus>(
                  elevation: 0,
                  color: Colors.white,
                  position: PopupMenuPosition.under,
                  padding: .zero,
                  iconColor: Colors.white,
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (status) => Navigator.pop(context, status),
                  itemBuilder: (ctx) {
                    final items = <PopupMenuEntry<ComplaintStatus>>[];
                    if (complaint.status == .pending) {
                      items.add(
                        PopupMenuItem(
                          value: ComplaintStatus.inProgress,
                          child: PopupMenuItemWidget(
                            title: localizations.markAsInProgress,
                            icon: Icons.hourglass_bottom_outlined,
                          ),
                        ),
                      );
                    }
                    if (complaint.status == .pending || complaint.status == .inProgress) {
                      items.add(
                        PopupMenuItem(
                          value: ComplaintStatus.resolved,
                          child: PopupMenuItemWidget(
                            title: localizations.markAsResolved,
                            icon: Icons.check_box_outlined,
                          ),
                        ),
                      );
                      items.add(
                        PopupMenuItem(
                          value: ComplaintStatus.rejected,
                          child: PopupMenuItemWidget(
                            title: localizations.reject,
                            icon: Icons.close,
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                )
              else
                const SizedBox(width: 40)
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
                    future: UserService.instance.getUserByID(userID: complaint.complaintBy),
                    builder: (ctx, snapshot) {
                      final complaintByUser = snapshot.data;
                      return Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(localizations.aboutResident, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
                          Padding(
                            padding: const .only(top: 10.0),
                            child: Row(
                              spacing: 10,
                              children: [
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
                                      Text(complaintByUser?.userName ?? 'Unknown', style: AppTextStyles.tileTitleTextStyle),
                                      Text(complaintByUser?.phoneNum ?? 'Unknown', style: AppTextStyles.tileTitleTextStyle),
                                    ],
                                  ),
                                ),
                                ComplaintStatusWidget(status: complaint.status)
                                /*PopupMenuButton<ComplaintStatus>(
                                    elevation: 0,
                                    color: Colors.white,
                                    position: PopupMenuPosition.under,
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.more_vert_rounded),
                                    // onSelected: (status) => provider.updateComplaintStatus(complaint: complaint.copyWith(status: status)),
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem(
                                        value: ComplaintStatus.resolved,
                                        child: PopupMenuItemWidget(title: localizations.markAsResolved, icon: Icons.check_box_outlined),
                                      ),
                                      PopupMenuItem(
                                        value: ComplaintStatus.inProgress,
                                        child: PopupMenuItemWidget(title: localizations.markAsInProgress, icon: Icons.hourglass_bottom_outlined),
                                      ),
                                      PopupMenuItem(
                                        value: ComplaintStatus.rejected,
                                        child: PopupMenuItemWidget(title: localizations.reject, icon: Icons.close),
                                      ),
                                    ],
                                  ),*/
                              ],
                            ),
                          ),
                          Padding(
                            padding: const .only(top: 15.0),
                            child: VisitorInfoItemWidget(title: localizations.email, subTitle: complaintByUser?.email ?? 'Unknown'),
                          ),
                          VisitorInfoItemWidget(title: localizations.houseNumber, subTitle: '#${complaintByUser?.houseNumber ?? '706'}', showDivider: true,)
                        ],
                      );
                    },
                  ),
                  Text(localizations.aboutComplaint, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
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
                                  title: 'Date', subTitle: DateTimeFormatHelpers.formatDateTime(complaint.createdAt), ),
                              ),
                              Expanded(
                                  child: VisitorInfoItemWidget(
                                    title: 'Status', subTitle: complaint.status.name.toUpperCase(),)
                              ),
                            ],
                          ),
                          VisitorInfoItemWidget(title: 'Complaint', subTitle: complaint.complaint, showDivider: true),
                          Text("Photos", style: AppTextStyles.visitorDetailTitleTextStyle,),
                          Expanded(child: GridView.builder(
                              itemCount: complaint.images.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,   mainAxisSpacing: 10, crossAxisSpacing: 10), itemBuilder: (ctx, index){
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(imageUrl: ImageUrlHelper.getImageUrl(complaint.images[index]), height: 75, fit: BoxFit.cover,),
                            );
                          }))
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
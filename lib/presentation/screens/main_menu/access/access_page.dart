import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/access_model.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/access_request_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../../providers/request_access_provider.dart';
import '../../../../router/app_router.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/date_range_filter_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/popup_menu_item_widget.dart';

class AccessMenu extends StatelessWidget{
  const AccessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => RequestAccessProvider(),
      builder: (ctx, _){
        return Consumer<RequestAccessProvider>(
          builder: (ctx, provider, _){
            return BgGradientScreen(
                floatingActionButton: provider.selectedFilter == provider.filters.last ? FloatingActionButton(
                  heroTag: 'AccessFAB',
                    onPressed: () => _onAddAccessTap(ctx, provider: provider, localization: localization),
                    shape: RoundedRectangleBorder(borderRadius: .circular(100)),child: Icon(Icons.add_rounded, color: AppColors.primaryColor,)) : null,
                child: Stack(
                  children: [
                    Padding(
                      padding: const .symmetric(horizontal: 10.0),
                      child: Column(
                        spacing: 10,
                        children: [
                          Align(
                              alignment: .center,
                              child: Padding(
                                padding: const .only(top: 35.0,),
                                child: Text(
                                  localization.accessRequests, textAlign: .center,
                                  style: AppTextStyles.headingTextStyle,),
                              )),
                          const SizedBox(height: 10,),
                          Row(
                              spacing: 20,
                              children: List.generate(provider.filters.length, (index){
                                bool isSelected = provider.selectedFilter == provider.filters[index];
                                return ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: isSelected ? AppColors.btnColor: Colors.white),
                                    onPressed: ()=> provider.onFilterUpdated(provider.filters[index]), child: Text(provider.filters[index], style: AppTextStyles.tabsTextStyle.copyWith(color: isSelected ? Colors.white : AppColors.primaryColor),));
                              })
                          ),
                          if(provider.selectedFilter == provider.filters.first)
                            DateRangeFilterWidget(
                              dateFrom: provider.dateFrom,
                              dateTo: provider.dateTo,
                              onDateFromChanged: provider.onDateFromChanged,
                              onDateToChanged: provider.onDateToChanged,
                            ),
                            Expanded(
                              child: provider.selectedFilter == provider.filters.first
                                  ? _buildAccessRequestWidget(context, localization: localization, accessRequests: provider.filteredAccessRequests, provider: provider)
                                  : _buildAccessWidget(context, provider: provider, localizations: localization),
                          )
                        ],
                      ),
                    ),
                    if(provider.addingRequestAccess || provider.updatingRequest || provider.addingAccess)
                      FullPageLoadingWidget()
                  ],
                ));
          },
        );
      },
    );
  }

  Widget _buildAccessRequestWidget(BuildContext context, {required AppLocalizations localization, required List<AccessRequestModel> accessRequests, required RequestAccessProvider provider}) {
    return provider.loadingRequests ? LoadingWidget() : RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: accessRequests.length,
        itemBuilder: (ctx, index) {
          AccessRequestModel request = accessRequests[index];
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                FutureBuilder(
                    future: provider.getUserByID(userID: request.requestByUID),
                    builder: (ctx, snapshot) {
                      UserModel? complaintByUser = snapshot.data;
                      return Padding(
                        padding: const .all(8.0),
                        child: Row(
                          spacing: 10,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: .circular(10)
                              ),
                              child: ClipRRect(
                                borderRadius: .circular(10),
                                child: (complaintByUser?.profileImg != null &&
                                        complaintByUser!.profileImg!.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: complaintByUser.profileImg!,
                                        height: 50,
                                        width: 50,
                                        fit: .cover,
                                      )
                                    : Container(
                                        height: 50,
                                        width: 50,
                                        color: Colors.grey.shade200,
                                        alignment: .center,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(complaintByUser?.userName ?? 'Unknown', style: AppTextStyles.tileTitleTextStyle,),
                                  Text(complaintByUser?.phoneNum ?? 'Unknown', style: AppTextStyles.tileTitleTextStyle,),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                                elevation: 0,
                                color: Colors.white,
                                position: .under,
                                padding: .zero,
                                icon: Icon(Icons.more_vert_rounded),
                                onSelected: (status) => provider.updateRequestStatus(request: request.copyWith(status: status)),
                                itemBuilder: (ctx) {
                                  return [
                                    PopupMenuItem(
                                        value: RequestStatus.approved,
                                        child: PopupMenuItemWidget(title: localization.approve, icon: Icons.check_box_outlined)),
                                    PopupMenuItem(
                                        value: RequestStatus.rejected,
                                        child: PopupMenuItemWidget(title: localization.reject, icon: Icons.close)),
                                  ];
                                })
                          ],
                        ),
                      );
                    }),

                ListTile(
                  onTap: ()=> _onRequestItemTap(context, provider: provider, request: request),
                  contentPadding: .symmetric(horizontal: 15),
                  leading: SizedBox(height: 40, width: 40, child: CachedNetworkImage(imageUrl: request.requestedAccessImage, height: 40,),),
                  title: Text(request.requestedAccessTitle, style: AppTextStyles.tileTitleTextStyle),
                  subtitle: Text(
                    DateTimeFormatHelpers.formatDateTime(request.createdAt),
                    style: AppTextStyles.tileSubtitleTextStyle,),
                  trailing: Container(
                    decoration: BoxDecoration(
                        borderRadius: .circular(99),
                        color: provider.getColorByStatus(request.status).withValues(alpha: 0.1)
                    ),
                    padding: .symmetric(horizontal: 15, vertical: 5),
                    child: Text(request.status.name.toUpperCase(), style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: provider.getColorByStatus(request.status)),),
                  ),
                ),
              ],
            ),
          );
        },
        ),
    );
  }

  Widget _buildAccessWidget(BuildContext context, {required RequestAccessProvider provider, required AppLocalizations localizations}) {
    return provider.loadingAccess 
        ? LoadingWidget() 
        : RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (ctx, index){
          AccessModel access = provider.allAccessItems[index];
          return Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: .circular(15), side: BorderSide(color: AppColors.borderColor2)),
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 10),
              leading: CircleAvatar(
                backgroundColor: AppColors.btnColor,
                backgroundImage: CachedNetworkImageProvider(access.image),
              ),
              title: Text(access.name, style: AppTextStyles.tileTitleTextStyle,),
              subtitle: Text(DateTimeFormatHelpers.formatDateTime(.now()), style: AppTextStyles.tileSubtitleTextStyle,),
              trailing: Row(
                mainAxisSize: .min,
                children: [
                  if(access.freeToUse)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Text(
                        localizations.freeToUse,
                        style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: AppColors.primaryColor),
                      ),
                    ),
                  PopupMenuButton<int>(
                    elevation: 0,
                    color: Colors.white,
                    position: PopupMenuPosition.under,
                    padding: .zero,
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (val) {
                      if (val == 1) {
                        provider.onDeleteAccessTap(access: access);
                      } else if (val == 2) {
                        provider.onToggleFreeToUseAccess(access);
                      } else if (val == 3) {
                        provider.onEditAccessTap(access);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 3,
                        child: PopupMenuItemWidget(
                          title: localizations.update,
                          icon: Icons.edit_outlined,
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: PopupMenuItemWidget(
                          title: localizations.delete,
                          icon: Icons.delete,
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: PopupMenuItemWidget(
                          title: access.freeToUse
                              ? localizations.setItRequestToUse
                              : localizations.setItFreeToUse,
                          icon: Icons.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
    }, separatorBuilder: (_, index) => const SizedBox(height: 10,), itemCount: provider.allAccessItems.length),
        );
  }

  void _onRequestItemTap(BuildContext context, {required RequestAccessProvider provider,required AccessRequestModel request}) async{
   final result = await context.push(NamedRoutes.accessRequestDetail.routeName, extra: request);
   if(result != null){
     RequestStatus status = result as RequestStatus;
     provider.updateRequestStatus(request: request.copyWith(status: status));
   }
  }

  Future<void> _onAddAccessTap(BuildContext context, {required RequestAccessProvider provider, required AppLocalizations localization}) async {
    final access = await provider.onAddAccessTap();
    if (!context.mounted) return;
    if (access != null) {
      CommonUI.showSnackBarMessage(context, message: localization.accessCreated(access.name), isSuccess: true);
    } else if (provider.error != null) {
      CommonUI.showSnackBarMessage(context, message: localization.failedToCreateAccess, isError: true);
    }
  }
}

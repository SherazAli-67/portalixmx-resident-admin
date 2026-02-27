import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/complaints_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../../providers/maintenance_provider.dart';
import '../../../../router/app_router.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/loading_widget.dart';

class MaintenanceMenu extends StatelessWidget{
  const MaintenanceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=> MaintenanceProvider(),
      builder: (ctx, _){
        return Consumer<MaintenanceProvider>(builder: (ctx, provider, _){
          return BgGradientScreen(
            floatingActionButton: FloatingActionButton(onPressed: ()=> provider.onAddComplaintTap(), shape: RoundedRectangleBorder(borderRadius: .circular(100)), child: Icon(Icons.add_rounded, color: AppColors.primaryColor,)),
            child: Padding(
              padding: const .symmetric(horizontal: 10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: .start,
                children: [
                  Align(
                      alignment: .center,
                      child: Padding(
                        padding: const .only(top: 35.0, bottom: 11),
                        child: Text(AppLocalizations.of(context)!.maintenance, textAlign: .center, style: AppTextStyles.headingTextStyle,),
                      )),
                  Row(
                    spacing: 20,
                    children: List.generate(provider.filters.length, (index){
                      bool isSelected = provider.selectedFilter == provider.filters[index];
                      return ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: isSelected ? AppColors.btnColor: Colors.white),
                          onPressed: ()=> provider.onFilterUpdated(provider.filters[index]), child: Text(provider.filters[index], style: AppTextStyles.tabsTextStyle.copyWith(color: isSelected ? Colors.white : AppColors.primaryColor),));
                    })
                  ),
                  Expanded(
                      child: provider.loadingComplaints ? LoadingWidget() : ListView.builder(
                          itemCount: provider.filteredComplaints.length,
                          itemBuilder: (ctx, index){
                            ComplaintModel complaint = provider.filteredComplaints[index];
                            return Card(
                              margin: .only(bottom: 10),
                              child: ListTile(
                                onTap: ()=> context.push(NamedRoutes.complaintSummary.routeName, extra: complaint),
                                contentPadding: .only(left: 15),
                                title: Text(complaint.complaint, style: AppTextStyles.tileTitleTextStyle),
                                subtitle: Text(DateTimeFormatHelpers.formatDateTime(complaint.createdAt), style: AppTextStyles.tileSubtitleTextStyle,),
                                trailing: PopupMenuButton(
                                    elevation: 0,
                                    color: Colors.white,
                                    position: .under,
                                    padding: .zero,
                                    icon: Icon(Icons.more_vert_rounded),
                                    onSelected: (_)=> provider.deleteComplaintByID(complaint.id),
                                    itemBuilder: (ctx){
                                      return [
                                        PopupMenuItem(
                                            value: 1,
                                            child: Text(AppLocalizations.of(context)!.deleteComplaint))
                                      ];
                                    }),
                              ),
                            );
                          }))
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
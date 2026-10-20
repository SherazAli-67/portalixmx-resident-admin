import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../router/app_router.dart';
import '../../../core/models/community_event_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/community_calendar_provider.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/loading_widget.dart';
class CommunityCalendarPage extends StatefulWidget {
  const CommunityCalendarPage({super.key});

  @override
  State<CommunityCalendarPage> createState() => _CommunityCalendarPageState();
}

class _CommunityCalendarPageState extends State<CommunityCalendarPage> {
   final TextEditingController _searchController = .new();

   late AppLocalizations _localization;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_)=> CommunityCalendarProvider(),
      builder: (ctx, child){
        return Consumer<CommunityCalendarProvider>(
          builder: (_, provider, _){
            return BgGradientScreen(
              child: Stack(
                children: [
                  Column(
                    spacing: 20,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 65.0),
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            BackButton(color: Colors.white),
                            Text(_localization.communityCalendar, style: AppTextStyles.regularTextStyle),
                            Align(
                              alignment: .topRight,
                              child: Padding(
                                padding: const .only(right: 10.0),
                                child: IconButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor),
                                    onPressed: ()=> onCreateEventTap(provider: provider), icon: Icon(Icons.add, color: Colors.white,)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Card(
                          color: AppColors.lightGreyBackgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: provider.loadingCommunityEvents
                                  ? LoadingWidget(color: AppColors.primaryColor,)
                                  : provider.communityEvents.isEmpty ? Center(child: Text("No Events yet",),)
                                  : ListView.builder(
                                  itemCount: provider.communityEvents.length,
                                  itemBuilder: (ctx, index){
                                    CommunityEventModel event = provider.communityEvents[index];
                                    return Padding(
                                      padding: const .only(bottom: 10.0),
                                      child: Material(
                                        color: AppColors.lightGreyBackgroundColor,
                                        child: ListTile(
                                          onTap: ()=> context.push(NamedRoutes.communityCalendarDetail.routeName, extra: event),
                                          contentPadding: .symmetric(vertical: 8, horizontal: 15),
                                          shape: RoundedRectangleBorder(borderRadius: .circular(15)),
                                          tileColor: Colors.white,
                                          title: Column(
                                            crossAxisAlignment: .start,
                                            children: [
                                              Text(event.eventTitle, style: AppTextStyles.tileTitleTextStyle,),
                                              Text(DateTimeFormatHelpers.getCommunityDateTime(event.eventDate, event.eventTime), style: AppTextStyles.tileSubtitleTextStyle,)
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: .min,
                                            children: [
                                              if (event.imageUrl.isNotEmpty)
                                                SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: ClipRRect(
                                                    borderRadius: .circular(10),
                                                    child: CachedNetworkImage(
                                                      imageUrl: event.imageUrl,
                                                      fit: .cover,
                                                    ),
                                                  ),
                                                ),
                                              IconButton(
                                                onPressed: () => onDeleteEventTap(event: event, provider: provider),
                                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(provider.addingEvent)
                    FullPageLoadingWidget()
                ],
              ),
            );
          },
        );
      },
    );
  }

  void onCreateEventTap({required CommunityCalendarProvider provider}) async{
    final event = await provider.onCreateEventTap();
    if(event == null){
      CommonUI.showSnackBarMessage(context, message: _localization.failedToCreateEvent, isError: true);
    }else{
      CommonUI.showSnackBarMessage(context, message: _localization.eventCreated(event.eventTitle), isSuccess: true);
    }
  }

  Future<void> onDeleteEventTap({required CommunityEventModel event, required CommunityCalendarProvider provider})async{
    final error = await provider.deleteEvent(event: event);
    if(error != null){
      CommonUI.showSnackBarMessage(context, message: error, isError: true);
    }else{
      CommonUI.showSnackBarMessage(context, message: _localization.eventDeleted(event.eventTitle), isSuccess: true);
    }
  }
}

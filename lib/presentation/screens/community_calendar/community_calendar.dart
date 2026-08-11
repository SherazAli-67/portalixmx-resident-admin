import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=> CommunityCalendarProvider(),
      builder: (ctx, child){
        return Consumer<CommunityCalendarProvider>(
          builder: (_, provider, _){
            return BgGradientScreen(
              child: Column(
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65.0),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        BackButton(color: Colors.white),
                        Text(AppLocalizations.of(context)!.communityCalendar, style: AppTextStyles.regularTextStyle),
                        Align(
                          alignment: .topRight,
                          child: Padding(
                            padding: const .only(right: 10.0),
                            child: IconButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor),
                                onPressed: provider.onCreateEventTap, icon: Icon(Icons.add, color: Colors.white,)),
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
                                      trailing: SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(imageUrl:event.imageUrl, fit: BoxFit.cover,)),
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
            );
          },
        );
      },
    );
  }
}

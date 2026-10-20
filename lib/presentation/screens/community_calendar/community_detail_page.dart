import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../core/models/community_event_model.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';

class CommunityDetailPage extends StatelessWidget{
  const CommunityDetailPage({super.key, required this.event});
  final CommunityEventModel event;
  @override
  Widget build(BuildContext context) {
    return BgGradientScreen(child: Column(
      spacing: 20,
      children: [
        Padding(padding: EdgeInsets.only(top: 65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(color: Colors.white,),
              Text(event.eventTitle, style: AppTextStyles.regularTextStyle,),
              const SizedBox(width: 20)
            ],
          ),
        ),

        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: .zero,
            shape: RoundedRectangleBorder(
                borderRadius: .only(topLeft: .circular(30), topRight: .circular(30))
            ),
            child: Container(
              width: .infinity,
                padding: const .only(top: 36.0, left: 18, right: 18),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 15,
                  children: [
                    if(event.imageUrl.isNotEmpty)
                    ClipRRect(
                        borderRadius: .circular(10),
                        child: CachedNetworkImage(imageUrl: event.imageUrl, height: 200, width: .infinity, fit: .cover,)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.eventTitle, style: AppTextStyles.bottomSheetHeadingTextStyle.copyWith(color: AppColors.darkGreyColor),),
                        Text(DateTimeFormatHelpers.getCommunityDateTime(event.eventDate, event.eventTime), style: AppTextStyles.emergencyContactTitleTextStyle,),
                      ],
                    ),
                    Text(event.eventDescription, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff666666)),)
                  ],
                )
            ),
          ),
        )
      ],
    ),);
  }

}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/community_poll_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';

class CommunityPollsDetailPage extends StatelessWidget {
  const CommunityPollsDetailPage({super.key, required this.poll});
  final CommunityPollModel poll;

  @override
  Widget build(BuildContext context) {
    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(color: Colors.white),
                Text(AppLocalizations.of(context)!.communityPolls, style: AppTextStyles.regularTextStyle),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(poll.createdBy, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGreyColor2)),
                          if (poll.endsAt != null)
                            Text("Ends ${DateTimeFormatHelpers.formatDateTime(poll.endsAt!)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGreyColor2)),
                        ],
                      ),
                      Text(poll.question, maxLines: 5, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
                      if (poll.imageUrl != null && poll.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(imageUrl: poll.imageUrl!, fit: BoxFit.cover),
                        ),
                      Column(
                        spacing: 8,
                        children: poll.options.map((option) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: AppColors.greyColor2),
                              color: const Color(0xffEFEEFF).withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Text(option.text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primaryColor)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

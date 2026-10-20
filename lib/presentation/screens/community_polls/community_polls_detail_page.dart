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
    final totalVotes = poll.options.fold<int>(0, (sum, o) => sum + o.voteCount);
    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const .only(top: 65),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                const BackButton(color: Colors.white),
                Text(AppLocalizations.of(context)!.communityPolls, style: AppTextStyles.regularTextStyle),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const .symmetric(horizontal: 18),
              child: Card(
                child: Padding(
                  padding: const .all(15.0),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(
                            poll.createdBy,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: .w500,
                              color: AppColors.darkGreyColor2,
                            ),
                          ),
                          if (poll.endsAt != null)
                            Text(
                              "Ends ${DateTimeFormatHelpers.formatDateTime(poll.endsAt!)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: .w500,
                                color: AppColors.darkGreyColor2,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        poll.question,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 20, fontWeight: .w500, color: Colors.black),
                      ),
                      if (poll.imageUrl != null && poll.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: .circular(10),
                          child: CachedNetworkImage(imageUrl: poll.imageUrl!,fit: .cover, height: 200, width: .infinity,),
                        ),
                      Text(
                        'Results ($totalVotes votes)',
                        style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.btnColor),
                      ),
                      Column(
                        spacing: 8,
                        children: poll.options.map((option) {
                          final percent = totalVotes == 0 ? 0.0 : option.voteCount / totalVotes;
                          return Container(
                            width: .infinity,
                            decoration: BoxDecoration(
                              borderRadius: .circular(13),
                              border: .all(color: AppColors.greyColor2),
                              color: const Color(0xffEFEEFF).withValues(alpha: 0.3),
                            ),
                            padding: const .all(15),
                            child: Column(
                              spacing: 8,
                              crossAxisAlignment: .start,
                              children: [
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option.text,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: .w500,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${option.voteCount} (${(percent * 100).toStringAsFixed(0)}%)',
                                      style: AppTextStyles.tileTitleTextStyle,
                                    ),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: .circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 6,
                                    backgroundColor: AppColors.greyColor2.withValues(alpha: 0.3),
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/community_poll_model.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/community_polls_provider.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../../router/app_router.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/loading_widget.dart';

class CommunityPollsPage extends StatelessWidget {
  const CommunityPollsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => CommunityPollsProvider(),
      child: Consumer<CommunityPollsProvider>(
        builder: (_, provider, __) {
          return BgGradientScreen(
            child: Stack(
              children: [
                Column(
                  spacing: 20,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 65),
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          BackButton(color: Colors.white),
                          Text(localization.communityPolls, style: AppTextStyles.regularTextStyle),
                          Align(
                            alignment: .topRight,
                            child: Padding(
                              padding: const .only(right: 10.0),
                              child: IconButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor),
                                  onPressed: () => _onCreatePollTap(context, provider: provider, localization: localization),icon: Icon(Icons.add, color: Colors.white,)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          child: provider.loadingCommunityPolls
                              ? LoadingWidget(color: AppColors.primaryColor)
                              : provider.communityPolls.isEmpty
                                  ? const Center(child: Text('No polls yet'))
                                  : ListView.builder(
                                      itemCount: provider.communityPolls.length,
                                      itemBuilder: (ctx, index) {
                                        final poll = provider.communityPolls[index];
                                        return GestureDetector(
                                          onTap: () => context.push(NamedRoutes.communityPollsDetail.routeName, extra: poll),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 15,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: AppColors.btnColor,
                                                    child: const Center(child: Icon(Icons.person, color: Colors.white)),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(poll.createdBy, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.postGreyColor)),
                                                  const Spacer(),
                                                  Text(DateTimeFormatHelpers.formatDateTime(poll.createdAt)),
                                                ],
                                              ),
                                              if (poll.imageUrl != null && poll.imageUrl!.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius: .circular(10),
                                                  child: CachedNetworkImage(imageUrl: poll.imageUrl!, fit: .cover, height: 200, width: .infinity,),
                                                ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(poll.question, style: AppTextStyles.tileTitleTextStyle),
                                                  ),
                                                  IconButton(
                                                    onPressed: () => _onDeletePollTap(context, poll: poll, provider: provider, localization: localization),
                                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
                if(provider.addingPoll)
                  FullPageLoadingWidget()
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onCreatePollTap(BuildContext context, {required CommunityPollsProvider provider, required AppLocalizations localization}) async {
    final result = await provider.onCreatePollTap(context);
    if (!context.mounted || result == null) return;
    if (result) {
      CommonUI.showSnackBarMessage(context, message: localization.pollCreated, isSuccess: true);
    } else {
      CommonUI.showSnackBarMessage(context, message: localization.failedToCreatePoll, isError: true);
    }
  }

  Future<void> _onDeletePollTap(BuildContext context, {required CommunityPollModel poll, required CommunityPollsProvider provider, required AppLocalizations localization}) async {
    final error = await provider.deletePoll(poll);
    if (!context.mounted) return;
    if (error != null) {
      CommonUI.showSnackBarMessage(context, message: localization.failedToDeletePoll, isError: true);
    } else {
      CommonUI.showSnackBarMessage(context, message: localization.pollDeleted, isSuccess: true);
    }
  }
}

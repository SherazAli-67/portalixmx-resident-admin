import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/bg_gradient_screen.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/providers/transfer_admin_provider.dart';
import 'package:provider/provider.dart';

class TransferOwnershipPage extends StatelessWidget {
  const TransferOwnershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransferAdminProvider(),
      child: const _TransferOwnershipView(),
    );
  }
}

class _TransferOwnershipView extends StatelessWidget {
  const _TransferOwnershipView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BgGradientScreen(
      child: Consumer<TransferAdminProvider>(
        builder: (ctx, provider, _) {
          return Stack(
            children: [
              Column(
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(color: Colors.white),
                        Text(
                          localizations.transferOwnership,
                          style: AppTextStyles.regularTextStyle,
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: provider.loading
                          ? const LoadingWidget(color: AppColors.primaryColor)
                          : _buildBody(context, provider, localizations),
                    ),
                  ),
                ],
              ),
              if (provider.transferring)
                const FullPageLoadingWidget(color: AppColors.primaryColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransferAdminProvider provider,
    AppLocalizations localizations,
  ) {
    if (provider.error == 'not_owner') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            localizations.notSocietyOwner,
            textAlign: TextAlign.center,
            style: AppTextStyles.tileTitleTextStyle,
          ),
        ),
      );
    }
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.tileTitleTextStyle,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 18, right: 18, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.transferOwnershipDescription,
            style: AppTextStyles.tileTitleTextStyle,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.selectNewAdmin,
            style: AppTextStyles.editProfileHeadingTextStyle,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: provider.candidates.isEmpty
                ? Center(
                    child: Text(
                      localizations.noTransferCandidates,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tileTitleTextStyle,
                    ),
                  )
                : ListView.separated(
                    itemCount: provider.candidates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final candidate = provider.candidates[index];
                      final selected =
                          provider.selectedCandidate?.userID == candidate.userID;
                      return _CandidateTile(
                        candidate: candidate,
                        selected: selected,
                        statusLabel: candidate.status == UserStatus.approved
                            ? localizations.approved
                            : localizations.pending,
                        onTap: () => provider.selectCandidate(candidate),
                      );
                    },
                  ),
          ),
          if (provider.candidates.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: PrimaryBtn(
                onTap: () => _onTransferTap(context, provider, localizations),
                btnText: localizations.transferOwnership,
                isLoading: provider.transferring,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onTransferTap(
    BuildContext context,
    TransferAdminProvider provider,
    AppLocalizations localizations,
  ) async {
    final candidate = provider.selectedCandidate;
    if (candidate == null) {
      CommonUI.showSnackBarMessage(
        context,
        isError: true,
        message: localizations.selectNewAdmin,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.confirmTransfer),
        content: Text(
          localizations.confirmTransferMessage(candidate.userName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(localizations.confirmTransfer),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await provider.transferOwnership();
    if (!context.mounted) return;
    if (error != null) {
      CommonUI.showSnackBarMessage(
        context,
        isError: true,
        message: error,
      );
    }
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.selected,
    required this.statusLabel,
    required this.onTap,
  });

  final UserModel candidate;
  final bool selected;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: selected ? AppColors.primaryColor : AppColors.borderColor2,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.btnColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          candidate.userName,
          style: AppTextStyles.tileTitleTextStyle,
        ),
        subtitle: Text(
          '${candidate.email} · $statusLabel',
          style: AppTextStyles.tileSubtitleTextStyle,
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
            : null,
      ),
    );
  }
}

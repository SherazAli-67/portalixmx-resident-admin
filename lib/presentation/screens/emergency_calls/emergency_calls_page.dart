import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_icons.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/bg_gradient_screen.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/popup_menu_item_widget.dart';
import 'package:portalixmx_resident_admin/providers/emergency_calls_provider.dart';
import 'package:portalixmx_resident_admin/services/emergency_service/emergency_service.dart';
import 'package:provider/provider.dart';

class EmergencyCallsPage extends StatelessWidget {
  const EmergencyCallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmergencyCallsProvider(),
      child: const _EmergencyCallsView(),
    );
  }
}

class _EmergencyCallsView extends StatelessWidget {
  const _EmergencyCallsView();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Consumer<EmergencyCallsProvider>(
      builder: (ctx, provider, _) {
        return BgGradientScreen(
          floatingActionButton: FloatingActionButton(
            heroTag: 'EmergencyFAB',
            onPressed: () => _onAddContacts(context, provider, localization),
            shape: RoundedRectangleBorder(borderRadius: .circular(100)),
            child: Icon(Icons.add_rounded, color: AppColors.primaryColor),
          ),
          child: Stack(
            children: [
              Column(
                spacing: 20,
                children: [
                  Padding(
                    padding: const .only(top: 65.0),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        const BackButton(color: Colors.white),
                        Text(
                          localization.emergencyCalls,
                          style: AppTextStyles.regularTextStyle,
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: AppColors.lightGreyBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(30),
                      ),
                      child: Padding(
                        padding: const .symmetric(horizontal: 15.0, vertical: 10),
                        child: provider.loading
                            ? const LoadingWidget(color: AppColors.primaryColor)
                            : Column(
                                children: [
                                  Padding(
                                    padding: const .only(top: 35.0),
                                    child: _EmergencyHoldButton(
                                      sending: provider.sending,
                                      onHoldComplete: () =>
                                          _onHoldComplete(context, provider, localization),
                                    ),
                                  ),
                                  Padding(
                                    padding: const .only(top: 12),
                                    child: Text(
                                      localization.holdToSendAlert,
                                      textAlign: .center,
                                      style: AppTextStyles.tileSubtitleTextStyle,
                                    ),
                                  ),

                                  Expanded(
                                    child: provider.contacts.isEmpty
                                        ? Center(
                                            child: Text(
                                              localization.emptyEmergencyContactsMsg,
                                              textAlign: .center,
                                              style: AppTextStyles.tileTitleTextStyle,
                                            ),
                                          )
                                        : ListView.separated(
                                            itemCount: provider.contacts.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 10),
                                            itemBuilder: (ctx, index) {
                                              final contact = provider.contacts[index];
                                              return _EmergencyContactTile(
                                                contact: contact,
                                                localization: localization,
                                                onRemove: () => _onRemoveContact(
                                                  context,
                                                  provider,
                                                  localization,
                                                  contact.userID,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              if (provider.saving || provider.sending)
                const FullPageLoadingWidget(color: AppColors.primaryColor),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onAddContacts(
    BuildContext context,
    EmergencyCallsProvider provider,
    AppLocalizations localization,
  ) async {
    final saved = await provider.onAddContactsTap(context);
    if (saved == false && context.mounted) {
      CommonUI.showSnackBarMessage(
        context,
        isError: true,
        message: localization.somethingWentWrong,
      );
    }
  }

  Future<void> _onRemoveContact(
    BuildContext context,
    EmergencyCallsProvider provider,
    AppLocalizations localization,
    String userID,
  ) async {
    final saved = await provider.removeContact(userID);
    if (!saved && context.mounted) {
      CommonUI.showSnackBarMessage(
        context,
        isError: true,
        message: localization.somethingWentWrong,
      );
    }
  }

  Future<void> _onHoldComplete(
    BuildContext context,
    EmergencyCallsProvider provider,
    AppLocalizations localization,
  ) async {
    final result = await provider.sendAlert();
    if (!context.mounted) return;
    switch (result) {
      case EmergencyAlertResult.success:
        CommonUI.showSnackBarMessage(
          context,
          isSuccess: true,
          message: localization.emergencyAlertSent,
        );
      case EmergencyAlertResult.noContacts:
        CommonUI.showSnackBarMessage(
          context,
          isError: true,
          message: localization.noEmergencyContacts,
        );
      case EmergencyAlertResult.noReachable:
        CommonUI.showSnackBarMessage(
          context,
          isError: true,
          message: localization.noReachableContacts,
        );
      case EmergencyAlertResult.failed:
        CommonUI.showSnackBarMessage(
          context,
          isError: true,
          message: localization.somethingWentWrong,
        );
    }
  }
}

class _EmergencyContactTile extends StatelessWidget {
  const _EmergencyContactTile({
    required this.contact,
    required this.localization,
    required this.onRemove,
  });

  final UserModel contact;
  final AppLocalizations localization;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightGreyBackgroundColor,
      child: ListTile(
        contentPadding: const .only(top: 8, bottom: 8, left: 15, right: 0),
        shape: RoundedRectangleBorder(borderRadius: .circular(15)),
        leading: CircleAvatar(
          backgroundColor: AppColors.btnColor,
          child: const Center(
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        tileColor: Colors.white,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Text(contact.userName, style: AppTextStyles.tileTitleTextStyle),
            Text(
              contact.phoneNum ?? contact.email,
              style: AppTextStyles.tileSubtitleTextStyle,
            ),
          ],
        ),
        trailing: PopupMenuButton<int>(
          elevation: 0,
          color: Colors.white,
          position: .under,
          padding: .zero,
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (_) => onRemove(),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 1,
              child: PopupMenuItemWidget(
                title: localization.removeContact,
                icon: Icons.delete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyHoldButton extends StatefulWidget {
  const _EmergencyHoldButton({
    required this.sending,
    required this.onHoldComplete,
  });

  final bool sending;
  final VoidCallback onHoldComplete;

  @override
  State<_EmergencyHoldButton> createState() => _EmergencyHoldButtonState();
}

class _EmergencyHoldButtonState extends State<_EmergencyHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener(_onStatus);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == .completed && !_completed) {
      _completed = true;
      widget.onHoldComplete();
    }
  }

  void _onPointerDown(PointerDownEvent _) {
    if (widget.sending) return;
    _completed = false;
    _controller.forward(from: 0);
  }

  void _onPointerEnd(PointerEvent _) {
    if (_completed) return;
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (ctx, _) {
          return SizedBox(
            height: 170,
            width: 170,
            child: Stack(
              alignment: .center,
              children: [
                SizedBox(
                  height: 170,
                  width: 170,
                  child: CircularProgressIndicator(
                    value: _controller.value == 0 ? 0 : _controller.value,
                    strokeWidth: 5,
                    color: AppColors.primaryColor,
                    backgroundColor: Colors.white24,
                  ),
                ),
                CircleAvatar(
                  radius: 75,
                  backgroundColor: AppColors.btnColor,
                  child: Center(
                    child: Padding(
                      padding: const .symmetric(horizontal: 15.0),
                      child: Column(
                        spacing: 10,
                        mainAxisAlignment: .center,
                        children: [
                          SvgPicture.asset(AppIcons.icEmergencyCalls, height: 42),
                          Text(
                            localization.emergencyCall,
                            textAlign: .center,
                            style: AppTextStyles.regularTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

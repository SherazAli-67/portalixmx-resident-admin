import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_icons.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/bg_gradient_screen.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
import 'package:portalixmx_resident_admin/services/auth_service/auth_service.dart';
import 'package:portalixmx_resident_admin/services/push_notification_service/push_notification_service.dart';
import 'package:provider/provider.dart';

class PendingRequestPage extends StatelessWidget {
  const PendingRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BgGradientScreen(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const .symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: .center,
              spacing: 16,
              children: [

                Image.asset(
                  AppIcons.accountPending,
                  height: 48,
                  width: 48,
                  color: Colors.white,
                ),
                FutureBuilder(
                  future: AuthService.instance.getSociety(),
                  builder: (ctx, snapshot) {
                    final societyName = snapshot.data?.name ?? 'Society';
                    return Text(
                      localization.accountRequestPending(societyName),
                      style: AppTextStyles.regularTextStyle.copyWith(color: Colors.white),
                      textAlign: .center,
                    );
                  },
                ),
                Text(
                  'Your account is awaiting approval. You can refresh or sign out.',
                  style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.white70),
                  textAlign: .center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: .infinity,
                  child: PrimaryBtn(
                    btnText: 'Refresh',
                    bgColor: Colors.white,
                    textColor: AppColors.primaryColor,
                    onTap: () => context.read<ProfileProvider>().reloadCurrentUser(),
                  ),
                ),
                SizedBox(
                  width: .infinity,
                  child: PrimaryBtn(
                    btnText: localization.logout,
                    onTap: () async {
                      await PushNotificationService.instance.removeTokenForSignOut();
                      await AuthService.instance.signOut();
                      if (context.mounted) context.go(NamedRoutes.login.routeName);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _recoveryRequested = false;

  void _maybeRecover(ProfileProvider profile) {
    final auth = FirebaseAuth.instance.currentUser != null;
    if (_recoveryRequested || profile.loadingProfile || profile.user != null || !auth) {
      return;
    }
    if (profile.profileLoadError == null) {
      _recoveryRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await context.read<ProfileProvider>().recoverFromFailedProfileLoad();
        if (!mounted) return;
        context.go(NamedRoutes.login.routeName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, p, _) {
            final auth = FirebaseAuth.instance.currentUser != null;
            final hasError = p.profileLoadError != null && auth && p.user == null;
            if (!p.loadingProfile && p.user == null && auth && p.profileLoadError == null) {
              _maybeRecover(p);
            }
            if (hasError) {
              final message = p.profileLoadError == 'profileLoadTimeout'
                  ? localization.profileLoadTimeoutMessage
                  : localization.appCheckErrorMessage;
              return Padding(
                padding: const .symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: .min,
                  spacing: 16,
                  children: [
                    Text(
                      localization.appCheckErrorTitle,
                      textAlign: .center,
                      style: AppTextStyles.headingTextStyle.copyWith(color: AppColors.primaryColor),
                    ),
                    Text(
                      message,
                      textAlign: .center,
                      style: AppTextStyles.regularTextStyle.copyWith(
                        color: AppColors.darkGreyColor2,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      width: .infinity,
                      height: 48,
                      child: PrimaryBtn(
                        onTap: () {
                          p.clearProfileLoadError();
                          p.reloadCurrentUser();
                        },
                        btnText: localization.retry,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await p.recoverFromFailedProfileLoad();
                        if (!context.mounted) return;
                        context.go(NamedRoutes.login.routeName);
                      },
                      child: Text(localization.logout),
                    ),
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

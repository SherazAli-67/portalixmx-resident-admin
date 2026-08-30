import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/core/res/app_constants.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/main_menu.dart';
import 'package:portalixmx_resident_admin/presentation/screens/webview/webview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/res/app_icons.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../router/app_router.dart';
import '../../../../services/push_notification_service/push_notification_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/profile_image_widget.dart';

class ProfileMenu extends StatelessWidget{
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 34,
          children: [
            Consumer<ProfileProvider>(builder: (ctx, provider, _){
              return  provider.loadingProfile
                  ? LoadingWidget()
                  : provider.user != null
                  ? Padding(
                padding: const EdgeInsets.only(top: 45.0),
                child: Column(
                  spacing: 5,
                  children: [
                    ProfileImageWidget(imageUrl: provider.user!.profileImg),
                    Text(provider.user!.userName, style: AppTextStyles.bottomSheetHeadingTextStyle.copyWith(color: Colors.white),),
                    InkWell(
                        onTap: ()=> context.push(NamedRoutes.editProfile.routeName),
                        child: Text(localizations.viewProfile, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),))
                  ],
                ),
              )
                  : const SizedBox();
            }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileItemWidget(title: localizations.communityCalendar, icon: AppIcons.icCalendar, onTap: ()=> context.push(NamedRoutes.communityCalendar.routeName)),
                ProfileItemWidget(title: localizations.communityPolls, icon: AppIcons.icCommunityPolls,  onTap: ()=> context.push(NamedRoutes.communityPolls.routeName)),
                ProfileItemWidget(title: localizations.fundManagement, icon: AppIcons.icPaymentsMenu, onTap: ()=> context.push(NamedRoutes.fundManagement.routeName)),
                ProfileItemWidget(title: localizations.paymentToAdmin, icon: AppIcons.icPaymentsMenu, onTap: ()=> context.push(NamedRoutes.paymentsToAdmin.routeName)),
                ProfileItemWidget(title: localizations.editCommunity, icon: AppIcons.icEdit, onTap: () => context.push(NamedRoutes.editCommunity.routeName)),
                ProfileItemWidget(title: localizations.directory, icon: AppIcons.icDirectory, onTap: () => context.push(NamedRoutes.communityDirectory.routeName)),
                ProfileItemWidget(title: localizations.emergencyCalls, icon: AppIcons.icEmergencyCalls, onTap: ()=> context.push(NamedRoutes.emergencyCall.routeName)),
                TextButton(onPressed: ()=> onPrivacyPolicyTap(localizations: localizations), child: Text(localizations.privacyPolicy, style: AppTextStyles.tileTitleTextStyle2, )),
                TextButton(onPressed: ()=> onTermsConditionTap(localizations: localizations), child: Text(localizations.termsCondition, style: AppTextStyles.tileTitleTextStyle2,)),
                TextButton(onPressed: ()=> _onLogoutTap(context), child: Text(localizations.logout, style: AppTextStyles.tileTitleTextStyle2,)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onLogoutTap(BuildContext context)async{

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    await PushNotificationService.instance.removeTokenForSignOut();
    await FirebaseAuth.instance.signOut();
    context.go(NamedRoutes.login.routeName);
  }

  void onPrivacyPolicyTap({required AppLocalizations localizations}){
    BottomSheetHelper.showDraggableListBottomSheet(scaffoldKey: scaffoldKey, contentBuilder:(controller, physics) => WebviewScreen(title: localizations.privacyPolicy, url: AppConstants.privacyPolicyUrl), initialHeight: 0.8);
  }

  void onTermsConditionTap({required AppLocalizations localizations}){
    BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: WebviewScreen(title: localizations.termsCondition, url: AppConstants.termsConditionUrl), initialHeight: 0.8);
  }
}

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    required String title, required String icon, required VoidCallback onTap,
  }) : _title = title, _icon = icon, _onTap = onTap;

  final String _title;
  final String _icon;
  final VoidCallback _onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _onTap,
      contentPadding: EdgeInsets.only(left: 15),
      leading: SvgPicture.asset(_icon, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
      title: Text(_title, style: AppTextStyles.tileTitleTextStyle2),
      trailing: IconButton(onPressed: _onTap, icon: Icon(Icons.navigate_next_rounded, color: Colors.white,)),
    );
  }
}
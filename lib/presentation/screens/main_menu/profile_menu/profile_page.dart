import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/res/app_icons.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../router/app_router.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/profile_image_widget.dart';

class ProfileMenu extends StatelessWidget{
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 34,
          children: [
            provider.loadingProfile
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
                      onTap: (){},
                      child: Text(AppLocalizations.of(context)!.viewProfile, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),))
                ],
              ),
            )
                : const SizedBox(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileItemWidget(title: AppLocalizations.of(context)!.communityCalendar, icon: AppIcons.icCalendar, onTap: (){}),
                ProfileItemWidget(title: AppLocalizations.of(context)!.communityPolls, icon: AppIcons.icCommunityPolls,  onTap: (){}),
                ProfileItemWidget(title: AppLocalizations.of(context)!.guards, icon: AppIcons.icGuards, onTap: (){}),
                ProfileItemWidget(title: AppLocalizations.of(context)!.carPooling, icon: AppIcons.icCarPooling, onTap: () {}),
                ProfileItemWidget(title: AppLocalizations.of(context)!.emergencyCalls, icon: AppIcons.icEmergencyCalls, onTap: (){}),
                TextButton(onPressed: (){}, child: Text(AppLocalizations.of(context)!.privacyPolicy, style: AppTextStyles.tileTitleTextStyle2,)),
                TextButton(onPressed: ()=> _onLogoutTap(context), child: Text(AppLocalizations.of(context)!.logout, style: AppTextStyles.tileTitleTextStyle2,)),
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
    context.go(NamedRoutes.login.routeName);
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
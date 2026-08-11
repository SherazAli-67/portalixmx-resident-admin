import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/helpers/url_launcher_helper.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_icons.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../widgets/bg_gradient_screen.dart';

class EmergencyCallsPage extends StatelessWidget{
  const EmergencyCallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<ProfileProvider>(context);

    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 65.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(color: Colors.white),
                Text("Emergency", style: AppTextStyles.regularTextStyle),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Card(
              color: AppColors.lightGreyBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: AppColors.btnColor,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Column(
                                spacing: 10,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppIcons.icEmergencyCalls, height: 42,),
                                  Text("EMERGENCY CALL", textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle,)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0, top: 20),
                        child: Material(
                          color: AppColors.lightGreyBackgroundColor,
                          child: ListTile(
                            onTap: ()=> UrlLauncherHelper.makePhoneCall('112'),
                            contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.btnColor,
                              child: Center(child: Icon(Icons.person, color: Colors.white,),),
                            ),
                            tileColor: Colors.white,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Emergency Contact", style: AppTextStyles.tileTitleTextStyle,),
                                Text('112', style: AppTextStyles.tileSubtitleTextStyle,)
                              ],
                            ),
                            trailing: CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.primaryColor,
                              child: Center(
                                child: Icon(Icons.call, color: Colors.white,),
                              ),
                            ),
                          ),
                        ),
                      )
                     /* Expanded(
                        child: ListView.builder(
                            itemCount: provider.user!.emergencyContacts.length,
                            itemBuilder: (ctx, index){
                              String contact = provider.user!.emergencyContacts[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Material(
                                  color: AppColors.lightGreyBackgroundColor,
                                  child: ListTile(
                                    onTap: (){},
                                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.btnColor,
                                      child: Center(child: Icon(Icons.person, color: Colors.white,),),
                                    ),
                                    tileColor: Colors.white,
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Emergency Contact", style: AppTextStyles.tileTitleTextStyle,),
                                        Text(contact, style: AppTextStyles.tileSubtitleTextStyle,)
                                      ],
                                    ),
                                    trailing: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: AppColors.primaryColor,
                                      child: Center(
                                        child: Icon(Icons.call, color: Colors.white,),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),*/
                    ],
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

}
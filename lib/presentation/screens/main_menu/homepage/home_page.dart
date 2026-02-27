import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/home_provider.dart';
import '../../../widgets/full_page_loading_widget.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_)=> HomeProvider(),
      builder: (ctx, child){
        return Stack(
          children: [
            Consumer<HomeProvider>(
              builder: (ctx, provider, child){
                return Stack(
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: const .symmetric(horizontal: 16.0, vertical: 20),
                        child: Column(
                          spacing: 20,
                          crossAxisAlignment: .start,
                          children: [
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: PopupMenuButton(
                                      elevation: 0,
                                      color: Colors.white,
                                      position: PopupMenuPosition.under,
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.add, color: Colors.white,),
                                      style: IconButton.styleFrom(backgroundColor: AppColors.btnColor),
                                      onSelected: (val){
                                        if(val ==1){
                                        }else {
                                        }
                                      },
                                      itemBuilder: (ctx){
                                        return [
                                          PopupMenuItem(
                                              value: 1,
                                              child: Text(localization.addGuest)),
                                          PopupMenuItem(
                                              value: 2,
                                              child: Text(localization.generateAccessCode)),

                                        ];
                                      }),
                                  /*      IconButton(
                                  style: IconButton.styleFrom(backgroundColor: AppColors.btnColor),
                                  onPressed: provider.onAddGuestTap, icon: Icon(Icons.add_rounded, color: Colors.white,)),*/
                                ),
                                FutureBuilder(future: provider.getCurrentUser(), builder: (ctx, snapshot){
                                  UserModel? user = snapshot.data;
                                  if(user != null){
                                    return Row(
                                      spacing: 10,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppColors.btnColor,
                                          child: Center(child:  Icon(Icons.person, color: Colors.white,),),
                                        ),
                                        Text(localization.welcomeMessage(user.userName), style: AppTextStyles.regularTextStyle,)
                                      ],
                                    );
                                  }
                                  return Text(localization.welcomeMessage(''), style: AppTextStyles.regularTextStyle,);
                                }),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                spacing: 20,
                                children: [
                                  Row(
                                    spacing: 20,
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: provider.selectedTab == 0 ?  AppColors.btnColor : Colors.white),
                                          onPressed: ()=> provider.onTabChange(0), child: Text(localization.regularVisitors, style: AppTextStyles.tabsTextStyle.copyWith(color: provider.selectedTab == 0 ?  Colors.white : AppColors.primaryColor),)),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: provider.selectedTab == 1 ?  AppColors.btnColor : Colors.white),
                                          onPressed: ()=> provider.onTabChange(1), child: Text(localization.guest, style: AppTextStyles.tabsTextStyle.copyWith(color: provider.selectedTab == 1 ?  Colors.white : AppColors.primaryColor),)),
                                    ],
                                  ),
                                  Center(child: Text("Selected tab: ${provider.selectedTab}"),)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if(provider.loading)
                      FullPageLoadingWidget()
                  ],
                );
              },
            ),

          ],
        );
      },
    );
  }
}


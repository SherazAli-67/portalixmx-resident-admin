import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/res/app_icons.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/filter_tab_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/resident_item_widget.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
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

    return Stack(
      children: [
        Consumer<HomeProvider>(
          builder: (ctx, provider, child){
            return Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                    child: RefreshIndicator(
                      onRefresh: () => provider.refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(future: provider.getCurrentUser(), builder: (ctx, snapshot){
                                UserModel? user = snapshot.data;
                                if(user != null){
                                  return Row(
                                    spacing: 10,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.btnColor,
                                        child: Center(child: Icon(Icons.person, color: Colors.white,),),
                                      ),
                                      Text(localization.welcomeMessage(user.userName), style: AppTextStyles.regularTextStyle,)
                                    ],
                                  );
                                }
                                return Text(localization.welcomeMessage(''), style: AppTextStyles.regularTextStyle,);
                              }),
                            ],
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(localization.dashboard, style: AppTextStyles.headingTextStyle.copyWith(fontSize: 20),),
                              Text(localization.dashboardDescription, style: AppTextStyles.subHeadingTextStyle),
                            ],
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(
                          child: Column(
                            spacing: 20,
                            children: [
                              Row(
                                spacing: 20,
                                children: [
                                  Expanded(child: _buildOverviewItemWidget(title: localization.totalResidents, icon: AppIcons.icUser, total: provider.totalResidents,),),
                                  Expanded(child: _buildOverviewItemWidget(title: localization.totalPayments, icon: AppIcons.icPaymentsMenu, total: provider.totalPayments)),
                                ],
                              ),
                              Row(
                                spacing: 20,
                                children: [
                                  Expanded(child: _buildOverviewItemWidget(title: localization.totalComplaints, icon: AppIcons.icMaintenance, total: provider.totalComplaints)),
                                  Expanded(child: _buildOverviewItemWidget(title: localization.totalAccess, icon: AppIcons.icAccess, total: provider.totalAccessRequests)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 30)),
                        SliverToBoxAdapter(
                          child: Text(provider.society?.name?? '', style: AppTextStyles.headingTextStyle.copyWith(fontSize: 20),),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    FilterTabWidget(isSelected: provider.selectedTab == .approved, onTap: ()=> provider.onTabChange(.approved), title: localization.residents),
                                    FilterTabWidget(isSelected: provider.selectedTab == .pending, onTap: ()=> provider.onTabChange(.pending), title: localization.newRequests),
                                  ],
                                ),
                              ),
                              
                              TextButton(onPressed: ()=> context.push(NamedRoutes.residents.routeName), child: Text(localization.viewAll, style: AppTextStyles.regularTextStyle,))
                            ],
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        if (provider.loadingResidents)
                          const SliverToBoxAdapter(child: SizedBox(height: 120, child: LoadingWidget()),),
                        if(provider.residents.isEmpty)
                          SliverToBoxAdapter(child: Column(
                            spacing: 10,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle
                                ),
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(top: 15),
                                child: SvgPicture.asset(
                                  AppIcons.icUser, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),),
                              ),
                              if(provider.selectedTab == .approved)
                                Text(localization.emptyResidentsMsg, style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.white),)
                              else
                                Text(localization.emptyResidentRequestsMsg, style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.white),)
                            ],
                          ),)
                        else
                          SliverList.separated(
                            itemBuilder: (ctx, index) => ResidentItemWidget(resident: provider.residents[index]),
                            separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                            itemCount: provider.residents.length,
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
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
  }

  Widget _buildOverviewItemWidget({required String icon, required String title, required int total, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.borderColor),
            color: Colors.white
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.btnColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                icon, colorFilter: ColorFilter.mode(AppColors.btnColor, BlendMode.srcIn),),
            ),
            Column(
              children: [
                Text(total.toString(), style: AppTextStyles.regularTextStyle.copyWith(
                    color: Colors.black),),
                Text(title,
                  style: AppTextStyles.tileSubtitleTextStyle,)
              ],
            )
          ],
        ),
      ),
    );
  }
}


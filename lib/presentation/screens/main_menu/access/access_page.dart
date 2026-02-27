import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/access_request_model.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_icons.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../../providers/request_access_provider.dart';
import '../../../../router/app_router.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/loading_widget.dart';

class AccessMenu extends StatelessWidget{
  const AccessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => RequestAccessProvider(),
      builder: (ctx, _){
        return  Consumer<RequestAccessProvider>(
          builder: (ctx, provider, _){
            return BgGradientScreen(
                paddingFromTop: 50,
                child: Stack(
                  children: [
                    Padding(
                      padding: const .symmetric(horizontal: 10.0),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              const SizedBox(width: 40,),
                              Text(localization.accessRequests, style: AppTextStyles.regularTextStyle,),
                              IconButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor),
                                  onPressed: ()=> provider.onAddRequestTap(), icon: Icon(Icons.add, color: Colors.white,)),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                              spacing: 20,
                              children: List.generate(provider.filters.length, (index){
                                bool isSelected = provider.selectedFilter == provider.filters[index];
                                return ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: isSelected ? AppColors.btnColor: Colors.white),
                                    onPressed: ()=> provider.onFilterUpdated(provider.filters[index]), child: Text(provider.filters[index], style: AppTextStyles.tabsTextStyle.copyWith(color: isSelected ? Colors.white : AppColors.primaryColor),));
                              })
                          ),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: provider.filteredAccessRequests.length,
                                  itemBuilder: (ctx, index){
                                    AccessRequestModel access = provider.filteredAccessRequests[index];
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        onTap: ()=> context.push(NamedRoutes.accessRequestDetail.routeName, extra: access),
                                        contentPadding: EdgeInsets.only(left: 15),
                                        leading: SvgPicture.asset(AppIcons.icGame, colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),),
                                        title: Text(access.requestedAccessTitle, style: AppTextStyles.tileTitleTextStyle),
                                        subtitle: Text(DateTimeFormatHelpers.formatDateTime(access.createdAt), style: AppTextStyles.tileSubtitleTextStyle,),
                                        trailing: IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_rounded)),
                                      ),
                                    );
                                  }))
                        ],
                      ),
                    ),
                    if(provider.addingRequestAccess)
                      LoadingWidget(color: Colors.white,)
                  ],
                ));
          },
        );
      },
    );
  }
}

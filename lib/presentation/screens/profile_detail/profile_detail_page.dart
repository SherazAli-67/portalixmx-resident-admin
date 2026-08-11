import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/providers/home_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_textstyles.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/vistor_info_item_widget.dart';

class ProfileDetailPage extends StatelessWidget{
  const ProfileDetailPage({super.key, required this.resident});
  final UserModel resident;
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BgGradientScreen(child: Column(
      spacing: 20,
      children: [
        Padding(padding: EdgeInsets.only(top: 65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(color: Colors.white,),
              Text(resident.userName, style: AppTextStyles.regularTextStyle,),
              const SizedBox(width: 20)
            ],
          ),
        ),

        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: .zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
            ),
            child: Padding(
                padding: const EdgeInsets.only(top: 36.0, left: 18, right: 18),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                   _buildInformationItemWidget(firstTitle: localization.name, firstValue: resident.userName, secondTitle: localization.joinedOn, secondValue: DateTimeFormatHelpers.formatDateTime(resident.createdAt)),
                    _buildInformationItemWidget(firstTitle: localization.email, firstValue: resident.email, secondTitle: localization.phone, secondValue: resident.phoneNum ?? ''),
                    Padding(
                      padding: const .symmetric(vertical: 16.0),
                      child: Text("Vehicle Information", style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
                    ),
                    _buildInformationItemWidget(firstTitle: localization.name, firstValue: resident.vehicleInformation?.name ?? '', secondTitle: localization.color, secondValue: resident.vehicleInformation?.color ?? ''),
                    _buildInformationItemWidget(firstTitle: localization.registrationNumber, firstValue: resident.vehicleInformation?.registrationNumber ?? '', secondTitle: localization.licensePlateNumber, secondValue: resident.vehicleInformation?.licensePlateNumber ?? ''),
                    Column(
                      crossAxisAlignment: .start,
                      spacing: 10,
                      children: [
                        Text("Emergency Contacts", style: AppTextStyles.visitorDetailTitleTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400),),
                        Column(
                            spacing: 5,
                            children: List.generate(3, (index){
                              return Text('+92307 2215 500', style: AppTextStyles.visitorDetailSubtitleTextStyle.copyWith(fontSize: 14),);
                            })
                        )
                      ],
                    ),
                    const Spacer(),
                    if(resident.status == .pending)
                      Consumer<HomeProvider>(builder: (ctx, provider, child){
                        return Container(
                          width: .infinity,
                          margin: .only(bottom: 45),
                          child: PrimaryBtn(onTap: ()async{
                            await provider.updateResident(resident.copyWith(status: .approved));
                            Navigator.pop(context);
                          }, btnText: localization.approve, isLoading: provider.updatingResidentStatus,),
                        );
                      })
                  ],
                )
            ),
          ),
        )
      ],
    ),);
  }

  _buildInformationItemWidget({required String firstTitle, required String firstValue, String? secondTitle, String? secondValue}) {
    return Column(
      children: [
        Row(
          spacing: 20,
          children: [
            Expanded(
              child: VisitorInfoItemWidget(
                title: firstTitle, subTitle: firstValue, ),
            ),
            if(secondTitle != null)
            Expanded(
                child: VisitorInfoItemWidget(
                  title: secondTitle, subTitle: secondValue!)
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
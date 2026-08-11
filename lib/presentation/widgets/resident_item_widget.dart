import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../router/app_router.dart';

class ResidentItemWidget extends StatelessWidget {
  const ResidentItemWidget({
    super.key,
    required this.resident,
    this.onTap,
    this.showStatus = false
  });

  final UserModel resident;
  final VoidCallback? onTap;
  final bool showStatus;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: .circular(15), side: BorderSide(color: AppColors.borderColor2)),
      child: ListTile(
        onTap: onTap ?? ()=> context.push(NamedRoutes.residentDetail.routeName, extra: resident),
        contentPadding: EdgeInsets.only(left: 10),
        leading: CircleAvatar(
          backgroundColor: AppColors.btnColor,
          child: Center(
            child:  Icon(Icons.person, color: Colors.white,),
          ),
        ),
        title: Text(resident.userName, style: AppTextStyles.tileTitleTextStyle,),
        subtitle: Text(resident.phoneNum ?? resident.vehicleInformation?.name ?? '', style: AppTextStyles.tileSubtitleTextStyle,),
        trailing: showStatus ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: AppColors.primaryColor.withValues(alpha: 0.1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          margin: .only(right: 10),
          child: Text(
            resident.status.name.toUpperCase(),
            style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: AppColors.primaryColor),
          ),
        ) : null,
      ),
    );
  }
}
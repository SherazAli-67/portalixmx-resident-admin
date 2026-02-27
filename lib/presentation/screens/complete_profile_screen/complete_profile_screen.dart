import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/common_ui.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_icons.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/authentication_provider/authentication_provider.dart';
import '../../../router/app_router.dart';
import '../../widgets/app_textfield_widget.dart';
import '../../widgets/bg_logo_screen.dart';
import '../../widgets/primary_btn.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _phoneNumController = .new();
  final TextEditingController _vehicleName = .new();
  final TextEditingController _vehicleColor = .new();
  final TextEditingController _licensePlateNum = .new();
  final TextEditingController _registrationNum = .new();
  final TextEditingController _emergencyContactNum = .new();

  @override
  void dispose() {
    super.dispose();
    _phoneNumController.dispose();
    _vehicleName.dispose();
    _vehicleColor.dispose();
    _licensePlateNum.dispose();
    _registrationNum.dispose();
    _emergencyContactNum.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ScreenWithBgLogo(
      child: Padding(
        padding: .all(16),
        child: Column(
          spacing: 16,
          children: [
            Text(localization.completeProfile, style: AppTextStyles.headingTextStyle,),
            Text(localization.completeProfileDescription, style: AppTextStyles.subHeadingTextStyle, textAlign: .center,),

            Expanded(
              child: SingleChildScrollView(padding: .only(top: 16), child: Column(
                spacing: 16,
                crossAxisAlignment: .start,
                children: [
                  Align(
                    alignment: .center,
                    child: GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 41,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 40,
                              // backgroundImage: provider.pickedImage != null
                              //     ? FileImage(File(provider.pickedImage!.path))
                              //     : null,
                              backgroundImage: AssetImage(AppIcons.icSplashLogo),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: .circle,
                                  color: AppColors.btnColor
                              ),
                              padding: .all(5),
                              child: Icon(
                                Icons.edit, color: Colors.white, size: 18,),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  AppTextField(title: localization.phone, controller: _phoneNumController, hintText: localization.phone, textInputType: .number,),
                  Text(localization.vehicleInformation, style:AppTextStyles.btnTextStyle),
                  AppTextField(hintText: localization.vehicleName, controller: _vehicleName,),
                  AppTextField(hintText: localization.color, controller: _vehicleColor,),
                  AppTextField(hintText: localization.licensePlateNumber, controller: _licensePlateNum,),
                  AppTextField(hintText: localization.registrationNumber, controller: _registrationNum,),
                  Text(localization.emergencyContacts, style:AppTextStyles.btnTextStyle),
                  AppTextField(hintText: localization.contactNum, textInputType: .number, controller: _emergencyContactNum,),
                  SizedBox(
                    width: .infinity,
                    child: PrimaryBtn(onTap: _onSignupTap,  btnText: localization.submit),
                  )
                ],
              ),),
            ),
          ],
        ),
      ),
    );
  }

  void _onSignupTap()async{
    String phoneNum = _phoneNumController.text.trim();
    String vehicleName = _vehicleName.text.trim();
    String color = _vehicleColor.text.trim();
    String licensePlateNum = _licensePlateNum.text.trim();
    String registrationNum = _registrationNum.text.trim();
    String emergencyContact = _emergencyContactNum.text.trim();

    final provider = Provider.of<AuthenticationProvider>(context, listen: false);

    String? isError = await provider.onCompleteProfileTap(phoneNum: phoneNum, vehicleName: vehicleName, vehicleColor: color, licensePlateNum: licensePlateNum, registrationNum: registrationNum, emergencyContact: emergencyContact);

    if(isError != null){
      CommonUI.showSnackBarMessage(context, isError: true, message: isError, title: "Signup failed");
    }else{
      context.go(NamedRoutes.home.routeName);
    }
  }
}

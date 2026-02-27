import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/common_ui.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_constants.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/authentication_provider/authentication_provider.dart';
import '../../../router/app_router.dart';
import '../../widgets/app_textfield_widget.dart';
import '../../widgets/bg_logo_screen.dart';
import '../../widgets/primary_btn.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final TextEditingController _emailController = .new();
  final TextEditingController _nameController = .new();
  final TextEditingController _passwordController = .new();
  late AuthenticationProvider _provider;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    _provider = Provider.of<AuthenticationProvider>(context);
    return ScreenWithBgLogo(
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 10.0),
        child: Column(
          spacing: 16,
          children: [
            Text(localization.createAccount, style: AppTextStyles.headingTextStyle),
            Text(localization.createAccountDescription, style: AppTextStyles.subHeadingTextStyle, textAlign: .center,),
            Expanded(
              child: SingleChildScrollView(
                padding: .only(top: 16),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 16,
                  children: [
                    Align(
                      alignment: .center,
                      child: GestureDetector(
                        onTap: _provider.onPickImageTap,
                        child: Stack(
                          children: [
                            CircleAvatar(
                                radius: 41,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _provider.pickedImage != null
                                      ? FileImage(File(_provider.pickedImage!.path))
                                      : null,
                                  // backgroundImage: AssetImage(AppIcons.icSplashLogo),
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
                                child: Icon(Icons.edit, color: Colors.white, size: 18,),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    AppTextField(title: localization.name, controller: _nameController, hintText: localization.name,),
                    AppTextField(title: localization.email, controller: _emailController, hintText: localization.email,textInputType: TextInputType.emailAddress,),
                    AppTextField(title: localization.password, controller: _passwordController, hintText: localization.password, isPassword: true,),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: PrimaryBtn(
                  onTap: _onSignupTap, btnText: localization.createAccount, isLoading: _provider.isSigningUp,),
            ),
            RichText(text: TextSpan(
                text: localization.alreadyHaveAnAccount,
                style: AppTextStyles.subHeadingTextStyle.copyWith(fontFamily: AppConstants.appFontFamily),
                children: [
                  TextSpan(
                      text: localization.login,
                      recognizer: TapGestureRecognizer()..onTap = ()=> context.go(NamedRoutes.login.routeName),
                      style: AppTextStyles.subHeadingTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, fontWeight: .w600)
                  )
                ]
            ))
          ],
        ),
      ),
    );
  }

  void _onSignupTap() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String? isError = await _provider.onCreateAccountTap(name: name, email: email, password: password);
    if(isError != null){
      CommonUI.showSnackBarMessage(context, isError: true, message: isError, title: "Signup failed");
    }else{
      context.push(NamedRoutes.completeProfile.routeName);
    }
  }
}

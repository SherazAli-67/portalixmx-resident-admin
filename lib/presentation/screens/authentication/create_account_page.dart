import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/validators/validators.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/app_dropdown_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/common_ui.dart';
import '../../../core/models/user_model.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_constants.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/authentication_provider/authentication_provider.dart';
import '../../../providers/profile_provider.dart';
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

  final _formKey = GlobalKey<FormState>();
  late AppLocalizations _localization;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     _localization = AppLocalizations.of(context)!;
    _provider = Provider.of<AuthenticationProvider>(context);
    return ScreenWithBgLogo(
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 10.0),
        child: Column(
          spacing: 16,
          children: [
            Text(_localization.createAccount, style: AppTextStyles.headingTextStyle),
            Text(_localization.createAccountDescription, style: AppTextStyles.subHeadingTextStyle, textAlign: .center,),
            Expanded(
              child: SingleChildScrollView(
                padding: .only(top: 16),
                child: Form(
                  key: _formKey,
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
                      AppTextField(title: _localization.name, controller: _nameController, hintText: _localization.name, validator: Validators.validateFullName,),
                      AppTextField(title: _localization.email, controller: _emailController, hintText: _localization.email,textInputType: TextInputType.emailAddress, validator: Validators.validateEmail,),
                      AppTextField(title: _localization.password, controller: _passwordController, hintText: _localization.password, isPassword: true, validator: Validators.validatePassword,),
                      if (_provider.loadingSocieties)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_provider.societiesError != null)
                        Column(
                          crossAxisAlignment: .start,
                          spacing: 8,
                          children: [
                            Text(
                              _localization.failedToLoadSocieties,
                              style: AppTextStyles.regularTextStyle.copyWith(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: _provider.loadSocieties,
                              child: Text(_localization.retry),
                            ),
                          ],
                        )
                      else
                        AppDropdownWidget<SocietyModel>(
                          title: _localization.selectSociety,
                          list: _provider.societies,
                          value: _provider.selectedSociety,
                          onChanged: (val) => _provider.onSelectSocietyTap(val),
                          getTitle: (item) => item.name,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: PrimaryBtn(
                  onTap: _onSignupTap, btnText: _localization.createAccount, isLoading: _provider.isSigningUp,),
            ),
            RichText(text: TextSpan(
                text: _localization.alreadyHaveAnAccount,
                style: AppTextStyles.subHeadingTextStyle.copyWith(fontFamily: AppConstants.appFontFamily),
                children: [
                  TextSpan(
                      text: _localization.login,
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
    if(_formKey.currentState?.validate() ?? false){
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String? isError = await _provider.onCreateAccountTap(localization: _localization, name: name, email: email, password: password);
      if (!mounted) return;
      if(isError != null){
        CommonUI.showSnackBarMessage(context, isError: true, message: isError, title: "Signup failed");
      }else{
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.reloadCurrentUser();
        if (!mounted) return;
        if (profileProvider.user?.status == UserStatus.pending) {
          context.go(NamedRoutes.pendingRequest.routeName);
        } else {
          context.go(NamedRoutes.home.routeName);
        }
      }
    }
  }
}

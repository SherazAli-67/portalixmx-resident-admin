import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/providers/authentication_provider/authentication_provider.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_constants.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../widgets/app_textfield_widget.dart';
import '../../widgets/bg_logo_screen.dart';
import '../../widgets/primary_btn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = .new();
  final TextEditingController _passwordController = .new();

  final bool _isLogging = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ScreenWithBgLogo(
      child: Padding(
        padding: .symmetric(horizontal: 16, vertical: 10.0),
        child: Column(
          spacing: 16,
          children: [
            Text(localization.residentLogin, style: AppTextStyles.headingTextStyle),
            Expanded(
              child: SingleChildScrollView(
                padding: .only(top: 16),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 16,
                  children: [
                    AppTextField(
                      title: localization.email,
                      controller: _emailController, hintText: localization.email,textInputType: TextInputType.emailAddress,),
                    AppTextField(title: localization.password,controller: _passwordController, hintText: localization.password, isPassword: true,),
                    Align(
                      alignment: .topRight,
                      child: TextButton(onPressed: ()=> context.push(NamedRoutes.forgetPassword.routeName), child: Text(localization.forgetPassword, style: AppTextStyles.btnTextStyle,)),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 50,
              width: .infinity,
              child: PrimaryBtn(onTap: _onLoginTap, btnText: localization.login, isLoading: _isLogging,),),
            RichText(text: TextSpan(
              text: localization.dontHaveAnAccount,
              style: AppTextStyles.subHeadingTextStyle.copyWith(fontFamily: AppConstants.appFontFamily),
              children: [
                TextSpan(
                  text: localization.createAccount,
                  recognizer: TapGestureRecognizer()..onTap = ()=> context.go(NamedRoutes.createAccount.routeName),
                  style: AppTextStyles.subHeadingTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, fontWeight: .w600)
                )
              ]
            ))
          ],
        ),
      ),
    );
  }

  void _onLoginTap()async{
    FocusManager.instance.primaryFocus?.unfocus();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      return;
    }

   UserModel? user =  await context.read<AuthenticationProvider>().onLoginTap(email: email, password: password);
    if (!mounted) return;
    if(user == null){
      CommonUI.showSnackBarMessage(context, isError: true, message: 'User not found!');
    }else if(user.status == .pending){
      context.go(NamedRoutes.pendingRequest.routeName);
    } else{
      await context.read<ProfileProvider>().reloadCurrentUser();
      if (!mounted) return;
      context.go(NamedRoutes.home.routeName);
    }
  }
}

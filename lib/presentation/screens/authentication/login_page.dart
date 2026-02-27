import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  bool _isLogging = false;

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
                      child: TextButton(onPressed: (){
                      }, child: Text(localization.forgetPassword, style: AppTextStyles.btnTextStyle,)),
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
    /*
    FocusManager.instance.primaryFocus?.unfocus();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      return;
    }

    setState(()=> _isLogging = true);
    final authRepo = AuthRepository();

    try {
      final response = await authRepo.loginUser(email: email, password: password);
      final responseMap = jsonDecode(response.body);
      
      if(responseMap['status']){
        String token = responseMap['data']['token']!['token'];
        String userID = responseMap['data']['token']!['userId'];
        String name = responseMap['data']['token']!['name'];
        // bool isResidentAdmin = responseMap['data']['token']!['role'] == 'admin';
        bool isResidentAdmin = true;
        // Calculate token expiry (24 hours from now)
        final tokenExpiry = DateTime.now().add(Duration(hours: 24));

        if (mounted) {
          setState(()=> _isLogging = false);
          final provider = Provider.of<UserInfoProvider>(context,listen: false);
          await provider.setUserInfo(
              token: token,
              name: name,
              userID: userID,
              email: email,
              isResidentAdmin: isResidentAdmin,
              expiry: tokenExpiry
          );

          if (mounted) {
            context.push(NamedRoutes.verifyOtp.routeName);
          }
        }
      } else {
        if (mounted) {
          Fluttertoast.showToast(msg: responseMap['message']);
        }
      }
    } catch(e) {
      debugPrint("Error while login user: ${e.toString()}");
      if (mounted) {
        Fluttertoast.showToast(msg: "Login failed. Please try again.");
      }
    }
    
    if (mounted) {
      setState(()=> _isLogging = false);
    }*/
  }
}

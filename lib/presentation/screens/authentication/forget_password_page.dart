import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/app_textfield_widget.dart';
import '../../widgets/bg_logo_screen.dart';
import '../../widgets/primary_btn.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key,});
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = .new();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ScreenWithBgLogo(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
        child: Column(
          spacing: 16,
          children: [
            Column(
              spacing: 10,
              children: [
                Text(localization.forgetPassword, style: AppTextStyles.headingTextStyle),
                Text(localization.enterEmailToSendPasswordReset, textAlign: .center, style: AppTextStyles.regularTextStyle.copyWith(fontSize: 14),),
              ],
            ),
            const SizedBox(height: 16,),
            AppTextField(controller: _emailController, hintText: localization.email, textInputType: .emailAddress,),
            const Spacer(),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: PrimaryBtn(onTap: ()=> onForgetPasswordTap(localization), btnText: localization.submit,),
            ),
          ],
        ),
      ),
    );
  }

  void onForgetPasswordTap(AppLocalizations localization)async{
    String email = _emailController.text.trim();
    if(email.isEmpty){
      Fluttertoast.showToast(msg: "Enter email address");
      return;
    }
    try{
     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
     CommonUI.showSnackBarMessage(context, isSuccess: true, title: localization.forgetPassLinkSent, message: localization.checkYourEmailAddress);
     Navigator.pop(context);
    }catch(e){
      CommonUI.showSnackBarMessage(context, message: e.toString(), isError: true, title: 'Failed to send reset password link');
    }
  }
}

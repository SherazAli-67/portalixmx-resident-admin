import 'package:flutter/material.dart';
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

  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ScreenWithBgLogo(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
        child: Column(
          spacing: 16,
          children: [
            Text(AppLocalizations.of(context)!.forgetPassword, style: AppTextStyles.headingTextStyle),
            const SizedBox(height: 16,),
            AppTextField(controller: _emailController, hintText: AppLocalizations.of(context)!.email, textInputType: .emailAddress,),
            const Spacer(),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: PrimaryBtn(onTap: (){}, btnText: AppLocalizations.of(context)!.submit,),
            ),
          ],
        ),
      ),
    );
  }

}

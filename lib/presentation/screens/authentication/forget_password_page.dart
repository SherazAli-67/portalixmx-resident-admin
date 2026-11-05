import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/helpers/formating_helper.dart';
import 'package:portalixmx_resident_admin/services/auth_service/auth_service.dart';
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
  bool _busy = false;
  String? _emailError;

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
        padding: const .symmetric(horizontal: 16, vertical: 10.0),
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
            if (_emailError != null)
              Align(
                alignment: .centerLeft,
                child: Text(
                  _emailError!,
                  style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.red),
                ),
              ),
            const Spacer(),
            SizedBox(
              height: 50,
              width: .infinity,
              child: PrimaryBtn(
                onTap: () => onForgetPasswordTap(localization),
                btnText: localization.submit,
                isLoading: _busy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onForgetPasswordTap(AppLocalizations localization) async {
    if (_busy) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = localization.enterEmailAddress);
      return;
    }
    if (!FormatingHelper.isValidEmail(email)) {
      setState(() => _emailError = localization.pleaseEnterValidEmail);
      return;
    }
    setState(() {
      _emailError = null;
      _busy = true;
    });
    try {
      await AuthService.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      CommonUI.showSnackBarMessage(
        context,
        isSuccess: true,
        title: localization.forgetPassLinkSent,
        message: localization.checkYourEmailAddress,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CommonUI.showSnackBarMessage(
        context,
        message: e.toString(),
        isError: true,
        title: localization.failedToSendResetLink,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

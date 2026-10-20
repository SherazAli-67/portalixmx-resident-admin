import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/common_ui.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/primary_btn.dart';

class AddPaymentSheet extends StatefulWidget{
  const AddPaymentSheet({super.key});

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  final TextEditingController _paymentForController = .new();
  final TextEditingController _descriptionController = .new();
  final TextEditingController _amountController = .new();

  final List<XFile> _pickedImages =  [];

  @override
  void dispose() {
    _paymentForController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          spacing: 15,
          mainAxisSize: .min,
          children: [
            Text(localization.paymentDetails, style: AppTextStyles.bottomSheetHeadingTextStyle,),
            const SizedBox(height: 10,),
            AppTextField(controller: _paymentForController, hintText: localization.paymentFor, fillColor: AppColors.fillColorGrey,),
            AppTextField(controller: _descriptionController, hintText: localization.description, fillColor: AppColors.fillColorGrey,),
            AppTextField(controller: _amountController, hintText: localization.amount, fillColor: AppColors.fillColorGrey, textInputType: .number,),


            Padding(
              padding: const .symmetric(vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: .infinity,
                child: PrimaryBtn(onTap: _onSubmitTap, btnText: localization.submit,),
              ),
            )
          ],
        ),
      ),
    );
  }



  void _onSubmitTap() {
    final paymentFor = _paymentForController.text.trim();
    final description = _descriptionController.text.trim();
    final amount = _amountController.text.trim();
    if (paymentFor.isEmpty) {
      CommonUI.showSnackBarMessage(context, isError: true, message: 'Please enter what this payment is for');
      return;
    }
    if (amount.isEmpty || double.tryParse(amount) == null) {
      CommonUI.showSnackBarMessage(context, isError: true, message: 'Please enter a valid amount');
      return;
    }
    Navigator.pop(context, {
      'paymentFor': paymentFor,
      'description': description,
      'amount': amount,
      'receipts': _pickedImages,
    });
  }
}
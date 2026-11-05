import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/helpers/formating_helper.dart';
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
  String? _paymentForError;
  String? _amountError;

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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const .symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                spacing: 15,
                children: [
                  Text(localization.paymentDetails, style: AppTextStyles.bottomSheetHeadingTextStyle,),
                  const SizedBox(height: 10,),
                  AppTextField(controller: _paymentForController, hintText: localization.paymentFor, fillColor: AppColors.fillColorGrey,),
                  if (_paymentForError != null)
                    Align(
                      alignment: .centerLeft,
                      child: Text(
                        _paymentForError!,
                        style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.red),
                      ),
                    ),
                  AppTextField(controller: _descriptionController, hintText: localization.description, fillColor: AppColors.fillColorGrey,),
                  AppTextField(controller: _amountController, hintText: localization.amount, fillColor: AppColors.fillColorGrey, textInputType: const TextInputType.numberWithOptions(decimal: true),),
                  if (_amountError != null)
                    Align(
                      alignment: .centerLeft,
                      child: Text(
                        _amountError!,
                        style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: .infinity,
                child: PrimaryBtn(onTap: _onSubmitTap, btnText: localization.submit,),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmitTap() {
    final localization = AppLocalizations.of(context)!;
    final paymentFor = _paymentForController.text.trim();
    final description = _descriptionController.text.trim();
    final amount = _amountController.text.trim();

    String? paymentForError;
    String? amountError;

    if (paymentFor.isEmpty) {
      paymentForError = localization.pleaseEnterPaymentFor;
    }

    switch (FormatingHelper.validatePaymentAmount(amount)) {
      case 'empty':
      case 'invalid':
        amountError = localization.pleaseEnterValidAmount;
      case 'decimals':
        amountError = localization.amountMaxTwoDecimalPlaces;
      case 'zero':
        amountError = localization.amountMustBeGreaterThanZero;
      case 'max':
        amountError = localization.amountExceedsMaximum;
      case null:
        break;
      default:
        amountError = localization.pleaseEnterValidAmount;
    }

    setState(() {
      _paymentForError = paymentForError;
      _amountError = amountError;
    });

    if (paymentForError != null || amountError != null) return;

    Navigator.pop(context, {
      'paymentFor': paymentFor,
      'description': description,
      'amount': FormatingHelper.normalizeAmountInput(amount),
      'receipts': _pickedImages,
    });
  }
}

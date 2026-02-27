import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class DropdownTextFieldWidget extends StatelessWidget{
  const DropdownTextFieldWidget(
      {super.key,
        required this.isEmpty,
        required this.selectedValue,
        required this.onChanged,
        required this.guestTypes,
        required this.hintText,
        this.borderRadius = 8
      });

  final bool isEmpty;
  final String? selectedValue;
  final Function(String? newValue) onChanged;
  final List<String> guestTypes;
  final String hintText;
  final double borderRadius;
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelStyle: AppTextStyles.hintTextStyle.copyWith(color: AppColors.hintTextColor),
            hintStyle: AppTextStyles.hintTextStyle.copyWith(color: AppColors.hintTextColor),
            contentPadding: .zero,
              enabledBorder: OutlineInputBorder(
              borderRadius: .circular(borderRadius),
              borderSide: BorderSide(color: AppColors.borderColor)
          ),
            filled: true,
            fillColor: AppColors.fillColorGrey
            // hintText: 'Please select expense',
          ),
          isEmpty: isEmpty,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String >(
              value: selectedValue,
              hint: Text(hintText),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              isDense: true,
              elevation: 0,
              dropdownColor: Colors.white,
              /*onChanged: (PlayerLevelModel? newValue) {
                setState(()=> _selectedPickleBallPlayerLevel = newValue);
              },*/
              onChanged: onChanged,
              items: guestTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

}
import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';

class AppDropdownWidget<T> extends StatelessWidget {
  final List<dynamic> list;
  final dynamic value;
  final Function(dynamic value) onChanged;
  final bool isResident;
  final String Function(T) getTitle;
  final String? title;
  const AppDropdownWidget({
    super.key,
    required this.list,
    this.value,
    required this.onChanged,
    this.isResident = true,
    required this.getTitle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 10,
      children: [
        if (title != null) Text(title!, style: AppTextStyles.regularTextStyle,),
        Container(
          height: 48,
          width: .infinity,
          foregroundDecoration: !isResident
              ? BoxDecoration(
            color: AppColors.fillColorGrey,
            borderRadius: .circular(8),
          )
              : null,
          padding: const .symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: AppColors.fillColorGrey,
              borderRadius: .circular(8)),
          child: DropdownButton<dynamic>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: 20,
            menuMaxHeight: 150,
            borderRadius: .circular(8),
            style: AppTextStyles.hintTextStyle,
            underline: const SizedBox(),
            hint: Text('Select',),
            onChanged: isResident ? onChanged : null,
            items: list.map<DropdownMenuItem<dynamic>>((dynamic value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  getTitle(value),
                  style: AppTextStyles.tileTitleTextStyle,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

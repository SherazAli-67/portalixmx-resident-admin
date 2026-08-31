import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/datetime_format_helpers.dart';

class DateRangeFilterWidget extends StatelessWidget {
  const DateRangeFilterWidget({
    super.key,
    this.dateFrom,
    this.dateTo,
    required this.onDateFromChanged,
    required this.onDateToChanged,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Row(
      spacing: 20,
      children: [
        Expanded(
          child: _DateField(
            title: localization.dateFrom,
            selectedDate: dateFrom,
            onTap: () => _pickDate(context, isFrom: true),
            onClear: dateFrom != null ? () => onDateFromChanged(null) : null,
          ),
        ),
        Expanded(
          child: _DateField(
            title: localization.dateTo,
            selectedDate: dateTo,
            onTap: () => _pickDate(context, isFrom: false),
            onClear: dateTo != null ? () => onDateToChanged(null) : null,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final now = DateTime.now();
    final minDate = DateTime(2020);
    final maxDate = now.add(const Duration(days: 365));

    DateTime firstDate = minDate;
    DateTime lastDate = maxDate;
    DateTime initialDate = now;

    if (isFrom) {
      lastDate = dateTo ?? maxDate;
      initialDate = dateFrom ?? dateTo ?? now;
    } else {
      firstDate = dateFrom ?? minDate;
      initialDate = dateTo ?? dateFrom ?? now;
    }

    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    if (isFrom) {
      onDateFromChanged(picked);
    } else {
      onDateToChanged(picked);
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.title,
    required this.onTap,
    this.selectedDate,
    this.onClear,
  });

  final String title;
  final VoidCallback onTap;
  final DateTime? selectedDate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 10,
      children: [
        Text(title, style: AppTextStyles.regularTextStyle),
        Container(
          height: 48,
          padding: const .only(left: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            color: AppColors.fillColorGrey,
            borderRadius: .circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Text(
                    selectedDate != null
                        ? DateTimeFormatHelpers.formatDateTime(selectedDate!)
                        : AppLocalizations.of(context)!.date,
                    style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.greyColor2),
                  ),
                ),
              ),
              IconButton(
                onPressed: onClear ?? onTap,
                icon: Icon(
                  onClear != null ? Icons.close : Icons.calendar_month_outlined,
                  color: AppColors.darkGreyColor2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

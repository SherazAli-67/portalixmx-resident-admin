import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/fund_report_model.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../widgets/bg_gradient_screen.dart';

class FundReportDetailPage extends StatelessWidget {
  const FundReportDetailPage({super.key, required this.report});
  final FundReportModel report;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const .only(top: 65),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                const BackButton(color: Colors.white),
                Text(localization.fundManagement,
                    style: AppTextStyles.regularTextStyle),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const .symmetric(horizontal: 18),
              child: Card(
                child: Padding(
                  padding: const .all(15.0),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              report.createdBy,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: .w500,
                                color: AppColors.darkGreyColor2,
                              ),
                            ),
                          ),
                          Text(
                            report.status == .published
                                ? localization.published
                                : localization.draft,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: .w600,
                              color: report.status == .published
                                  ? AppColors.btnColor
                                  : AppColors.serviceSubTitleGreyColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: .w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMM().format(
                            DateTime(report.periodYear, report.periodMonth)),
                        style: AppTextStyles.tileSubtitleTextStyle,
                      ),
                      Text(
                        DateTimeFormatHelpers.formatDateTime(report.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: .w500,
                          color: AppColors.serviceSubTitleGreyColor,
                        ),
                      ),
                      _buildSummaryRow(
                        label: localization.income,
                        value: '\$${report.income.toStringAsFixed(2)}',
                        valueColor: AppColors.btnColor,
                      ),
                      Text(
                        localization.expenses,
                        style: AppTextStyles.tileTitleTextStyle
                            .copyWith(color: AppColors.primaryColor),
                      ),
                      if (report.expenses.isEmpty)
                        Text(
                          localization.noExpenses,
                          style: AppTextStyles.tileSubtitleTextStyle,
                        )
                      else
                        Column(
                          spacing: 8,
                          children: report.expenses.map((expense) {
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: .circular(13),
                                border:
                                    Border.all(color: AppColors.greyColor2),
                                color: const Color(0xffEFEEFF)
                                    .withValues(alpha: 0.3),
                              ),
                              padding: const .all(15),
                              child: Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      expense.label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: .w500,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: .w700,
                                      color: AppColors.btnColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      _buildSummaryRow(
                        label: localization.totalExpenses,
                        value:
                            '\$${report.totalExpenses.toStringAsFixed(2)}',
                      ),
                      _buildSummaryRow(
                        label: localization.balance,
                        value: '\$${report.balance.toStringAsFixed(2)}',
                        valueColor: AppColors.btnColor,
                      ),
                      if (report.note.isNotEmpty) ...[
                        Text(
                          localization.note,
                          style: AppTextStyles.tileTitleTextStyle
                              .copyWith(color: AppColors.primaryColor),
                        ),
                        Text(
                          report.note,
                          style: AppTextStyles.emergencyContactTitleTextStyle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.tileTitleTextStyle
              .copyWith(color: AppColors.primaryColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: .w700,
            color: valueColor ?? AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}

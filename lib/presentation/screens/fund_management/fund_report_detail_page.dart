import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import '../../../core/common_ui.dart';
import '../../../core/helpers/bottom_sheet_helper.dart';
import '../../../core/models/fund_report_model.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/bottomsheets/create_fund_report_bottomsheet.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../../services/fund_reports_service/fund_reports_service.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/primary_btn.dart';

class FundReportDetailPage extends StatefulWidget {
  const FundReportDetailPage({super.key, required this.report});
  final FundReportModel report;

  @override
  State<FundReportDetailPage> createState() => _FundReportDetailPageState();
}

class _FundReportDetailPageState extends State<FundReportDetailPage> {
  late FundReportModel report;
  bool _publishing = false;
  bool _deleting = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    report = widget.report;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed ? report : null);
      },
      child: BgGradientScreen(
        child: Stack(
          children: [
            Column(
              spacing: 20,
              children: [
                Padding(
                  padding: const .only(top: 65),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      BackButton(
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context, _changed ? report : null),
                      ),
                      Text(localization.fundManagement,
                          style: AppTextStyles.regularTextStyle),
                      if (report.status == .draft)
                        IconButton(
                          onPressed: _deleting ? null : _onDeleteTap,
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                        )
                      else
                        const SizedBox(width: 48),
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
                                    width: .infinity,
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
                            if (report.status == .draft) ...[
                              SizedBox(
                                width: .infinity,
                                child: PrimaryBtn(
                                  btnText: localization.edit,
                                  bgColor: AppColors.primaryColor,
                                  onTap: _onEditTap,
                                ),
                              ),
                              SafeArea(
                                child: SizedBox(
                                  width: .infinity,
                                  child: PrimaryBtn(
                                    btnText: localization.publishReport,
                                    isLoading: _publishing,
                                    onTap: _onPublishTap,
                                  ),
                                ),
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
            if(_deleting)
              FullPageLoadingWidget()
          ],
        ),
      ),
    );
  }

  Future<void> _onPublishTap() async {
    final localization = AppLocalizations.of(context)!;
    setState(() => _publishing = true);
    try {
      final now = DateTime.now().toUtc();
      final published = report.copyWith(
        status: .published,
        publishedAt: now,
        showToResidents: true,
      );
      await FundReportsService.instance.updateReport(published);
      if (!mounted) return;
      setState(() {
        report = published;
        _changed = true;
      });
      Navigator.pop(context, report);
    } catch (_) {
      if (!mounted) return;
      CommonUI.showSnackBarMessage(
        context,
        message: localization.failedToPublishFundReport,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _onEditTap() async {
    final localization = AppLocalizations.of(context)!;
    final result =
        await BottomSheetHelper.showAdjustableModalBottomSheet<Map<String, dynamic>>(
      context: context,
      initialChildSize: 0.9,
      wrapChildInScrollView: false,
      child: CreateFundReportBottomSheet(initialReport: report),
    );
    if (result == null || !mounted) return;
    try {
      final expensesRaw = result['expenses'] as List<dynamic>? ?? [];
      final expenses = expensesRaw
          .map((e) => FundExpenseItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      final updated = report.copyWith(
        periodMonth: result['periodMonth'] as int? ?? report.periodMonth,
        periodYear: result['periodYear'] as int? ?? report.periodYear,
        title: result['title'] as String? ?? report.title,
        income: (result['income'] as num?)?.toDouble() ?? report.income,
        expenses: expenses,
        balance: (result['balance'] as num?)?.toDouble() ?? report.balance,
        note: result['note'] as String? ?? report.note,
        showToResidents:
            result['showReportToResident'] as bool? ?? report.showToResidents,
      );
      await FundReportsService.instance.updateReport(updated);
      if (!mounted) return;
      setState(() {
        report = updated;
        _changed = true;
      });
    } catch (_) {
      if (!mounted) return;
      CommonUI.showSnackBarMessage(
        context,
        message: localization.failedToUpdateFundReport,
        isError: true,
      );
    }
  }

  Future<void> _onDeleteTap() async {
    final localization = AppLocalizations.of(context)!;
    final confirmed = await CommonUI.confirmDelete(context);
    if (!confirmed || !mounted) return;
    setState(() => _deleting = true);
    try {
      await FundReportsService.instance.deleteReport(reportId: report.id);

      if (!mounted) return;
      Navigator.pop(context, {'deleted': true, 'id': report.id});
    } catch (_) {
      if (!mounted) return;
      CommonUI.showSnackBarMessage(
        context,
        message: localization.failedToDeleteFundReport,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
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

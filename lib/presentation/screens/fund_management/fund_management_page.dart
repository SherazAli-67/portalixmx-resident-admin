import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/datetime_format_helpers.dart';
import '../../../providers/fund_reports_provider.dart';
import '../../../router/app_router.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/loading_widget.dart';

class FundManagementPage extends StatelessWidget {
  const FundManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => FundReportsProvider(),
      child: Consumer<FundReportsProvider>(
        builder: (_, provider, __) {
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
                      Align(
                        alignment: .topRight,
                        child: Padding(
                          padding: const .only(right: 10.0),
                          child: IconButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.btnColor),
                            onPressed: () =>
                                provider.onCreateReportTap(context),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: .zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: .only(
                          topLeft: .circular(30), topRight: .circular(30)),
                    ),
                    child: Padding(
                      padding: const .only(left: 18, right: 18),
                      child: provider.loadingFundReports
                          ? LoadingWidget(color: AppColors.primaryColor)
                          : provider.fundReports.isEmpty
                              ? Center(
                                  child: Text(
                                    localization.emptyFundReportsMsg,
                                    style: AppTextStyles.tileSubtitleTextStyle,
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: provider.refresh,
                                  child: ListView.builder(
                                    itemCount: provider.fundReports.length,
                                    itemBuilder: (ctx, index) {
                                      final report =
                                          provider.fundReports[index];
                                      return GestureDetector(
                                        onTap: () => context.push(
                                          NamedRoutes
                                              .fundReportDetail.routeName,
                                          extra: report,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: .start,
                                          spacing: 12,
                                          children: [
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      AppColors.btnColor,
                                                  child: const Center(
                                                    child: Icon(Icons.account_balance_wallet,
                                                        color: Colors.white,
                                                        size: 18),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: .start,
                                                    spacing: 2,
                                                    children: [
                                                      Text(
                                                        report.title,
                                                        style: AppTextStyles
                                                            .tileTitleTextStyle,
                                                      ),
                                                      Text(
                                                        DateFormat.yMMMM()
                                                            .format(DateTime(
                                                                report
                                                                    .periodYear,
                                                                report
                                                                    .periodMonth)),
                                                        style: AppTextStyles
                                                            .tileSubtitleTextStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: .end,
                                                  spacing: 4,
                                                  children: [
                                                    Text(
                                                      '\$${report.balance.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: .w700,
                                                        color:
                                                            AppColors.btnColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      report.status ==
                                                              .published
                                                          ? localization
                                                              .published
                                                          : localization.draft,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: .w500,
                                                        color: report.status ==
                                                                .published
                                                            ? AppColors.btnColor
                                                            : AppColors
                                                                .serviceSubTitleGreyColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  '${localization.income}: \$${report.income.toStringAsFixed(2)}',
                                                  style: AppTextStyles
                                                      .emergencyContactTitleTextStyle,
                                                ),
                                                Text(
                                                  DateTimeFormatHelpers
                                                      .formatDateTime(
                                                          report.createdAt),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: .w500,
                                                    color: AppColors
                                                        .serviceSubTitleGreyColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

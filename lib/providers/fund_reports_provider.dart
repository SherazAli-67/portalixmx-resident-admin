import 'package:flutter/material.dart';
import '../core/helpers/bottom_sheet_helper.dart';
import '../core/models/fund_report_model.dart';
import '../core/models/user_model.dart';
import '../presentation/bottomsheets/create_fund_report_bottomsheet.dart';
import '../services/fund_reports_service/fund_reports_service.dart';
import '../services/user_service/user_service.dart';

class FundReportsProvider extends ChangeNotifier {
  bool loadingFundReports = false;
  final _userService = UserService.instance;
  final _fundReportsService = FundReportsService.instance;

  List<FundReportModel> _fundReports = [];

  List<FundReportModel> get fundReports => _fundReports;

  FundReportsProvider() {
    _initFundReports();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  Future<void> _initFundReports() async {
    try {
      loadingFundReports = true;
      notifyListeners();
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }
      _fundReports = await _fundReportsService.getReports(user.societyID);
      _fundReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      loadingFundReports = false;
      notifyListeners();
    } catch (e) {
      loadingFundReports = false;
      notifyListeners();
      debugPrint('Error loading fund reports: $e');
    }
  }

  Future<void> refresh() => _initFundReports();

  Future<void> onCreateReportTap(BuildContext context) async {
    final result =
        await BottomSheetHelper.showAdjustableModalBottomSheet<Map<String, dynamic>>(
      context: context,
      initialChildSize: 0.85,
      child: const CreateFundReportBottomSheet(),
    );
    if (result == null) return;
    final user = await getCurrentUser();
    if (user == null) return;

    final title = result['title'] as String? ?? '';
    if (title.isEmpty) return;

    final expensesRaw = result['expenses'] as List<dynamic>? ?? [];
    final expenses = expensesRaw
        .map((e) => FundExpenseItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final publish = result['publish'] as bool? ?? false;
    final now = DateTime.now().toUtc();
    final showReportToResident = result['showReportToResident'] as bool? ?? false;
    final report = FundReportModel(
      id: now.millisecondsSinceEpoch.toString(),
      societyID: user.societyID,
      createdBy: user.userName,
      createdByUID: user.userID,
      createdAt: now,
      periodMonth: result['periodMonth'] as int? ?? now.month,
      periodYear: result['periodYear'] as int? ?? now.year,
      title: title,
      income: (result['income'] as num?)?.toDouble() ?? 0,
      expenses: expenses,
      balance: (result['balance'] as num?)?.toDouble() ?? 0,
      note: result['note'] as String? ?? '',
      status: publish ? .published : .draft,
      publishedAt: publish ? now : null,
      showToResidents: showReportToResident
    );

    try {
      _fundReports.insert(0, report);
      notifyListeners();
      await _fundReportsService.createReport(report);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

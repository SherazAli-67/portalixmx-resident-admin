import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_dropdown_widget.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/primary_btn.dart';

class _ExpenseRowControllers {
  final TextEditingController label;
  final TextEditingController amount;

  _ExpenseRowControllers({
    required this.label,
    required this.amount,
  });

  void dispose() {
    label.dispose();
    amount.dispose();
  }
}

class CreateFundReportBottomSheet extends StatefulWidget {
  const CreateFundReportBottomSheet({super.key});

  @override
  State<CreateFundReportBottomSheet> createState() =>
      _CreateFundReportBottomSheetState();
}

class _CreateFundReportBottomSheetState
    extends State<CreateFundReportBottomSheet> {
  final TextEditingController _titleController = .new();
  final TextEditingController _incomeController = .new();
  final TextEditingController _balanceController = .new();
  final TextEditingController _noteController = .new();
  final List<_ExpenseRowControllers> _expenseRows = [];

  late int _selectedMonth;
  late int _selectedYear;
  bool _balanceManuallyEdited = false;
  bool _updatingBalanceProgrammatically = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _incomeController.addListener(_recalculateBalance);
    _balanceController.addListener(_onBalanceChanged);
    _addExpenseRow();
  }

  @override
  void dispose() {
    _incomeController.removeListener(_recalculateBalance);
    _balanceController.removeListener(_onBalanceChanged);
    _titleController.dispose();
    _incomeController.dispose();
    _balanceController.dispose();
    _noteController.dispose();
    for (final row in _expenseRows) {
      row.amount.removeListener(_recalculateBalance);
      row.dispose();
    }
    super.dispose();
  }

  void _onBalanceChanged() {
    if (!_updatingBalanceProgrammatically) {
      _balanceManuallyEdited = true;
    }
  }

  void _addExpenseRow() {
    final row = _ExpenseRowControllers(label: .new(), amount: .new());
    row.amount.addListener(_recalculateBalance);
    _expenseRows.add(row);
  }

  void _recalculateBalance() {
    if (_balanceManuallyEdited) return;
    final income = double.tryParse(_incomeController.text.trim()) ?? 0;
    final expenses = _expenseRows.fold<double>(0, (sum, row) {
      return sum + (double.tryParse(row.amount.text.trim()) ?? 0);
    });
    _updatingBalanceProgrammatically = true;
    _balanceController.text = (income - expenses).toStringAsFixed(2);
    _updatingBalanceProgrammatically = false;
  }

  List<int> get _years {
    final current = DateTime.now().year;
    return List.generate(6, (i) => current - 2 + i);
  }

  String _monthLabel(int month) {
    return DateFormat.MMMM().format(DateTime(2024, month));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 25),
        child: Column(
          mainAxisSize: .min,
          spacing: 15,
          children: [
            Text(l.createFundReport,
                style: AppTextStyles.bottomSheetHeadingTextStyle),
            const SizedBox(height: 10),
            AppTextField(
              controller: _titleController,
              hintText: l.reportTitle,
              fillColor: AppColors.fillColorGrey,
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: AppDropdownWidget<int>(
                    list: List.generate(12, (i) => i + 1),
                    title: l.month,
                    value: _selectedMonth,
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _selectedMonth = val as int);
                    },
                    getTitle: _monthLabel,
                  ),
                ),
                Expanded(
                  child: AppDropdownWidget<int>(
                    list: _years,
                    title: l.year,
                    value: _selectedYear,
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _selectedYear = val as int);
                    },
                    getTitle: (year) => year.toString(),
                  ),
                ),
              ],
            ),
            AppTextField(
              controller: _incomeController,
              hintText: l.income,
              fillColor: AppColors.fillColorGrey,
              textInputType: const TextInputType.numberWithOptions(decimal: true),
            ),
            Align(
              alignment: .centerLeft,
              child: Text(l.expenses,
                  style: AppTextStyles.regularTextStyle
                      .copyWith(color: AppColors.primaryColor)),
            ),
            ...List.generate(_expenseRows.length, (index) {
              return Row(
                spacing: 8,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _expenseRows[index].label,
                      hintText: l.expenseLabel,
                      fillColor: AppColors.fillColorGrey,
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: _expenseRows[index].amount,
                      hintText: l.amount,
                      fillColor: AppColors.fillColorGrey,
                      textInputType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  if (_expenseRows.length > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _expenseRows[index]
                              .amount
                              .removeListener(_recalculateBalance);
                          _expenseRows[index].dispose();
                          _expenseRows.removeAt(index);
                          _recalculateBalance();
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                ],
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() => _addExpenseRow());
              },
              icon: const Icon(Icons.add),
              label: Text(l.addExpense),
            ),
            AppTextField(
              controller: _balanceController,
              hintText: l.balance,
              fillColor: AppColors.fillColorGrey,
              textInputType: const TextInputType.numberWithOptions(decimal: true),
            ),
            AppTextField(
              controller: _noteController,
              hintText: l.note,
              fillColor: AppColors.fillColorGrey,
              maxLines: 3,
            ),
            Padding(
              padding: const .symmetric(vertical: 8.0),
              child: Column(
                spacing: 12,
                children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: PrimaryBtn(
                      onTap: () => _onSubmitTap(publish: true),
                      btnText: l.publishReport,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _onSubmitTap(publish: false),
                    child: Text(
                      l.saveAsDraft,
                      style: AppTextStyles.tileTitleTextStyle
                          .copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmitTap({required bool publish}) {
    final title = _titleController.text.trim();
    final income = double.tryParse(_incomeController.text.trim()) ?? 0;
    final balance = double.tryParse(_balanceController.text.trim());
    final expenses = <Map<String, dynamic>>[];
    for (var i = 0; i < _expenseRows.length; i++) {
      final label = _expenseRows[i].label.text.trim();
      final amountText = _expenseRows[i].amount.text.trim();
      if (label.isEmpty && amountText.isEmpty) continue;
      if (label.isEmpty) return;
      final amount = double.tryParse(amountText);
      if (amount == null) return;
      expenses.add({'id': '$i', 'label': label, 'amount': amount});
    }
    if (title.isEmpty) return;
    final resolvedBalance = balance ??
        (income -
            expenses.fold<double>(0, (s, e) => s + (e['amount'] as double)));
    Navigator.pop(context, {
      'title': title,
      'periodMonth': _selectedMonth,
      'periodYear': _selectedYear,
      'income': income,
      'expenses': expenses,
      'balance': resolvedBalance,
      'note': _noteController.text.trim(),
      'publish': publish,
    });
  }
}

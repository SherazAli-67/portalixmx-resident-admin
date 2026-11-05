import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/helpers/formating_helper.dart';
import '../../core/models/fund_report_model.dart';
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
  const CreateFundReportBottomSheet({super.key, this.initialReport});

  final FundReportModel? initialReport;

  @override
  State<CreateFundReportBottomSheet> createState() =>
      _CreateFundReportBottomSheetState();
}

class _CreateFundReportBottomSheetState extends State<CreateFundReportBottomSheet> {
  final TextEditingController _titleController = .new();
  final TextEditingController _incomeController = .new();
  final TextEditingController _balanceController = .new();
  final TextEditingController _noteController = .new();
  final List<_ExpenseRowControllers> _expenseRows = [];

  late int _selectedMonth;
  late int _selectedYear;
  bool showReportToResidents = false;
  String? _formError;

  bool get _isEditing => widget.initialReport != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialReport;
    final now = DateTime.now();
    _selectedMonth = initial?.periodMonth ?? now.month;
    _selectedYear = initial?.periodYear ?? now.year;
    if (initial != null) {
      _titleController.text = initial.title;
      _incomeController.text = initial.income.toStringAsFixed(2);
      _noteController.text = initial.note;
      showReportToResidents = initial.showToResidents;
      if (initial.expenses.isEmpty) {
        _addExpenseRow();
      } else {
        for (final expense in initial.expenses) {
          final row = _ExpenseRowControllers(
            label: TextEditingController(text: expense.label),
            amount: TextEditingController(text: expense.amount.toStringAsFixed(2)),
          );
          row.amount.addListener(_recalculateBalance);
          _expenseRows.add(row);
        }
      }
      _balanceController.text = initial.balance.toStringAsFixed(2);
    } else {
      _addExpenseRow();
    }
    _incomeController.addListener(_recalculateBalance);
    _recalculateBalance();
  }

  @override
  void dispose() {
    _incomeController.removeListener(_recalculateBalance);
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

  void _addExpenseRow() {
    final row = _ExpenseRowControllers(label: .new(), amount: .new());
    row.amount.addListener(_recalculateBalance);
    _expenseRows.add(row);
  }

  void _recalculateBalance() {
    final income = FormatingHelper.tryParseAmount(_incomeController.text) ?? 0;
    final expenses = _expenseRows.fold<double>(0, (sum, row) {
      return sum + (FormatingHelper.tryParseAmount(row.amount.text) ?? 0);
    });
    _balanceController.text = (income - expenses).toStringAsFixed(2);
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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const .symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                spacing: 15,
                children: [
                  Text(
                    _isEditing ? l.editFundReport : l.createFundReport,
                    style: AppTextStyles.bottomSheetHeadingTextStyle,
                  ),
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
                    child: Text(
                      l.expenses,
                      style: AppTextStyles.regularTextStyle
                          .copyWith(color: AppColors.primaryColor),
                    ),
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
                    readOnly: true,
                    textInputType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  AppTextField(
                    controller: _noteController,
                    hintText: l.note,
                    fillColor: AppColors.fillColorGrey,
                    maxLines: 3,
                  ),
                  if (_formError != null)
                    Align(
                      alignment: .centerLeft,
                      child: Text(
                        _formError!,
                        style: AppTextStyles.tileSubtitleTextStyle
                            .copyWith(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                spacing: 12,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        l.showReportToResidents,
                        style: AppTextStyles.regularTextStyle
                            .copyWith(color: AppColors.primaryColor),
                      ),
                      CupertinoSwitch(
                        value: showReportToResidents,
                        onChanged: (val) =>
                            setState(() => showReportToResidents = val),
                      ),
                    ],
                  ),
                  if (_isEditing)
                    SizedBox(
                      height: 50,
                      width: .infinity,
                      child: PrimaryBtn(
                        onTap: () => _onSubmitTap(publish: widget.initialReport!.status == .published),
                        btnText: l.save,
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 50,
                      width: .infinity,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmitTap({required bool publish}) {
    final l = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final incomeText = _incomeController.text.trim();
    final expenses = <Map<String, dynamic>>[];

    if (title.isEmpty) {
      setState(() => _formError = l.pleaseEnterReportTitle);
      return;
    }

    final income = FormatingHelper.tryParseAmount(incomeText);
    if (incomeText.isEmpty || income == null || income < 0) {
      setState(() => _formError = l.pleaseEnterValidIncome);
      return;
    }

    for (var i = 0; i < _expenseRows.length; i++) {
      final label = _expenseRows[i].label.text.trim();
      final amountText = _expenseRows[i].amount.text.trim();
      if (label.isEmpty && amountText.isEmpty) continue;
      if (label.isEmpty) {
        setState(() => _formError = l.pleaseEnterExpenseLabel);
        return;
      }
      final amount = FormatingHelper.tryParseAmount(amountText);
      if (amount == null || amount <= 0) {
        setState(() => _formError = l.expenseAmountMustBePositive);
        return;
      }
      expenses.add({'id': '$i', 'label': label, 'amount': amount});
    }

    final totalExpenses =
        expenses.fold<double>(0, (s, e) => s + (e['amount'] as double));
    final balance = income - totalExpenses;

    setState(() => _formError = null);
    Navigator.pop(context, {
      'title': title,
      'periodMonth': _selectedMonth,
      'periodYear': _selectedYear,
      'income': income,
      'expenses': expenses,
      'balance': balance,
      'note': _noteController.text.trim(),
      'publish': publish,
      'showReportToResident': showReportToResidents,
    });
  }
}

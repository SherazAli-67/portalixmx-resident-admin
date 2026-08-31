import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/payment_submitted_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/add_payment_sheet.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

import '../../core/helpers/bottom_sheet_helper.dart';
import '../../presentation/screens/main_menu/main_menu.dart';
import '../datetime_format_helpers.dart';

class PaymentStatusCounts {
  final int pending;
  final int submitted;
  final int received;

  const PaymentStatusCounts({
    this.pending = 0,
    this.submitted = 0,
    this.received = 0,
  });
}

class PaymentProvider extends ChangeNotifier{
  final _paymentsService = PaymentsService.instance;
  bool loadingPayments = false;
  bool addingPayment = false;
  String? error;
  int selectedFilterTab = 0;

  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;
  List<UserModel> _residents = [];
  Map<String, List<PaymentSubmittedModel>> _submissionsByPayment = {};

  PaymentProvider(){
    _initPayments();
  }

  DateTime? dateFrom;
  DateTime? dateTo;
  String? selectedPaymentStatusFilter;

  List<String> getStatusList(AppLocalizations localization){
    return [
      localization.pending,
      localization.submitted,
      localization.received,
    ];
  }

  PaymentStatusCounts getCountsFor(String paymentID) {
    final submissions = _submissionsByPayment[paymentID] ?? [];
    final residentIds = _residents.map((r) => r.userID).toSet();
    int submitted = 0;
    int received = 0;
    for (final submission in submissions) {
      if (!residentIds.contains(submission.paymentByUID)) continue;
      if (submission.approvedOnDate != null) {
        received++;
      } else {
        submitted++;
      }
    }
    final pending = (residentIds.length - submitted - received).clamp(0, residentIds.length);
    return PaymentStatusCounts(pending: pending, submitted: submitted, received: received);
  }

  List<PaymentModel> getFilteredPayments(AppLocalizations l10n) {
    PaymentStatus? statusFilter;
    if (selectedPaymentStatusFilter == l10n.pending) {
      statusFilter = .pending;
    } else if (selectedPaymentStatusFilter == l10n.submitted) {
      statusFilter = .submitted;
    } else if (selectedPaymentStatusFilter == l10n.received) {
      statusFilter = .received;
    }
    return _payments.where((p) {
      if (!DateTimeFormatHelpers.isInInclusiveDateRange(p.dateTime, dateFrom, dateTo)) return false;
      if (statusFilter != null && !_matchesStatus(p.paymentID, statusFilter)) return false;
      return true;
    }).toList();
  }

  bool _matchesStatus(String paymentID, PaymentStatus statusFilter) {
    final counts = getCountsFor(paymentID);
    switch (statusFilter) {
      case .pending:
        return counts.pending > 0;
      case .submitted:
        return counts.submitted > 0;
      case .received:
        return counts.received > 0;
    }
  }

  void _initPayments()async {
    loadingPayments = true;
    notifyListeners();
    try{
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
        error = "User not found";
        loadingPayments = false;
        notifyListeners();
        return;
      }
      _payments = await _paymentsService.getPayments(user.societyID);
      _payments.sort((a, b)=> b.dateTime.compareTo(a.dateTime));
      _residents = await ResidentsService.instance.loadResidentsOfSociety(societyID: user.societyID);
      await _loadSubmissions();
    }catch(e){
      error = e.toString();
    }
    loadingPayments = false;
    notifyListeners();
  }

  Future<void> _loadSubmissions() async {
    final entries = await Future.wait(_payments.map((payment) async {
      final submissions = await _paymentsService.getSubmissions(paymentID: payment.paymentID);
      return MapEntry(payment.paymentID, submissions);
    }));
    _submissionsByPayment = Map.fromEntries(entries);
  }

  Future<void> refreshPayments() async {
    loadingPayments = true;
    notifyListeners();
    try{
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
        error = "User not found";
        loadingPayments = false;
        notifyListeners();
        return;
      }
      _payments = await _paymentsService.getPayments(user.societyID);
      _payments.sort((a, b)=> b.dateTime.compareTo(a.dateTime));
      _residents = await ResidentsService.instance.loadResidentsOfSociety(societyID: user.societyID);
      await _loadSubmissions();
    }catch(e){
      error = e.toString();
    }
    loadingPayments = false;
    notifyListeners();
  }

  void onDateFromChanged(DateTime? date){
    dateFrom = date;
    notifyListeners();
  }

  void onDateToChanged(DateTime? date){
    dateTo = date;
    notifyListeners();
  }

  void onChangeStatusFilterTap(String val){
    selectedPaymentStatusFilter = val;
    notifyListeners();
  }
  void onAddPaymentTap()async {
    final result = await BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: AddPaymentSheet(), initialHeight: 0.7);
    if(result != null){
      String paymentFor = result['paymentFor'] ?? '';
      String description = result['description'] ?? '';
      String amount = result['amount'] ?? '0';
      List<XFile> receipts = result['receipts'] ?? [];
      try{
        addingPayment = true;
        notifyListeners();
        PaymentModel? payment = await _paymentsService.addPayment(paymentFor: paymentFor, description: description, amount: amount, receipts: receipts);
        if(payment != null){
          _payments.add(payment);
          _submissionsByPayment[payment.paymentID] = [];
        }
      }catch(e){
        error = e.toString();
      }
      addingPayment = false;
      notifyListeners();
    }
  }
}

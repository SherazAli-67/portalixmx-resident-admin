import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/add_payment_sheet.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

import '../../core/helpers/bottom_sheet_helper.dart';
import '../../presentation/screens/main_menu/main_menu.dart';

class PaymentProvider extends ChangeNotifier{
  final _paymentsService = PaymentsService.instance;
  bool loadingPayments = false;
  bool addingPayment = false;
  String? error;
  int selectedFilterTab = 0;

  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;

  PaymentProvider(){
    _initPayments();
  }

  String? selectedFilter;
  String? selectedPaymentStatusFilter;

  List<String> getFilterList(AppLocalizations localization){
    return [
      localization.all,
      localization.week,
      localization.month,
      localization.year
    ];
  }

  List<String> getStatusList(AppLocalizations localization){
    return [
      localization.pending,
      localization.received,
    ];
  }

  List<PaymentModel> getFilteredPayments(AppLocalizations l10n) {
    DateTime? dateCutoff;
    if (selectedFilter != null && selectedFilter != l10n.all) {
      if (selectedFilter == l10n.week) dateCutoff = DateTime.now().subtract(const Duration(days: 7));
      else if (selectedFilter == l10n.month) dateCutoff = DateTime.now().subtract(const Duration(days: 30));
      else if (selectedFilter == l10n.year) dateCutoff = DateTime.now().subtract(const Duration(days: 365));
    }
    PaymentStatus? statusFilter;
    if (selectedPaymentStatusFilter == l10n.pending) statusFilter = PaymentStatus.pending;
    else if (selectedPaymentStatusFilter == l10n.received) statusFilter = PaymentStatus.received;
    return _payments.where((p) {
      if (dateCutoff != null && p.dateTime.isBefore(dateCutoff)) return false;
      if (statusFilter != null && p.paymentStatus != statusFilter) return false;
      return true;
    }).toList();
  }

  void _initPayments()async {
    loadingPayments = true;
    notifyListeners();
    try{
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
        error = "User not found";
        return;
      }
      _payments = await _paymentsService.getPayments(user.societyID);
      _payments.sort((a, b)=> b.dateTime.compareTo(a.dateTime));
    }catch(e){
      error = e.toString();
    }
    loadingPayments = false;
    notifyListeners();
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
    }catch(e){
      error = e.toString();
    }
    loadingPayments = false;
    notifyListeners();
  }

  void onChangeFilterTap(String val){
    selectedFilter = val;
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
        }
      }catch(e){
        error = e.toString();
      }
      addingPayment = false;
      notifyListeners();
    }
  }

  void markPaymentAsReceived(PaymentModel payment)async {
    int index = payments.indexWhere((item)=> item.paymentID == payment.paymentID);
    final updatedPayment = payment.copyWith(paymentStatus: PaymentStatus.received);
    payments[index] = updatedPayment;
    notifyListeners();

    try{
      await _paymentsService.updatePayment(payment: updatedPayment,);
    }catch(e){
      error = e.toString();
    }
  }
}
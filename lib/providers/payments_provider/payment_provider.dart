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
    }catch(e){
      error = e.toString();
    }
    loadingPayments = false;
    notifyListeners();
  }

  void onChangeFilterTab(int index){
    selectedFilterTab = index;
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
    final result = await BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: AddPaymentSheet(),);
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
}
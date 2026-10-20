import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

class PaymentsToAdminProvider extends ChangeNotifier {
  final _paymentsService = PaymentsService.instance;
  bool loadingPayments = false;
  String? error;
  int selectedFilterTab = 0;

  bool updatingPayment = false;

  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;

  PaymentsToAdminProvider() {
    _initPayments();
  }

  String? selectedFilter;
  String? selectedPaymentStatusFilter;

  List<String> getFilterList(AppLocalizations localization) {
    return [localization.all, localization.week, localization.month, localization.year];
  }

  List<String> getStatusList(AppLocalizations localization) {
    return [localization.pending, localization.received];
  }

  List<PaymentModel> getFilteredPayments(AppLocalizations l10n) {
    DateTime? dateCutoff;
    if (selectedFilter != null && selectedFilter != l10n.all) {
      if (selectedFilter == l10n.week) {
        dateCutoff = DateTime.now().subtract(const Duration(days: 7));
      } else if (selectedFilter == l10n.month) {
        dateCutoff = DateTime.now().subtract(const Duration(days: 30));
      } else if (selectedFilter == l10n.year) {
        dateCutoff = DateTime.now().subtract(const Duration(days: 365));
      }
    }
    PaymentStatus? statusFilter;
    if (selectedPaymentStatusFilter == l10n.pending) {
      statusFilter = PaymentStatus.pending;
    } else if (selectedPaymentStatusFilter == l10n.received) statusFilter = PaymentStatus.received;
    return _payments.where((p) {
      if (dateCutoff != null && p.dateTime.isBefore(dateCutoff)) return false;
      if (statusFilter != null && p.paymentStatus != statusFilter) return false;
      return true;
    }).toList();
  }

  Future<void> refresh() => _initPayments();

  Future<void> _initPayments() async {
    loadingPayments = true;
    notifyListeners();
    try {
      final user = await UserService.instance.getCurrentUser();
      if (user == null) {
        error = "User not found";
        return;
      }
      _payments = await _paymentsService.getAdminPayments(user.societyID);
      _payments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      error = e.toString();
    }
    loadingPayments = false;
    notifyListeners();
  }

  void onChangeFilterTap(String val) {
    selectedFilter = val;
    notifyListeners();
  }

  void onChangeStatusFilterTap(String val) {
    selectedPaymentStatusFilter = val;
    notifyListeners();
  }

  Future<String?> updatePayment(PaymentModel updatedPayment, {XFile? receiptFile}) async {
    updatingPayment = true;
    notifyListeners();
    try {
      var payment = updatedPayment;
      if (receiptFile != null) {
        final url = await _paymentsService.uploadAdminReceipt(
          receipt: receiptFile,
          paymentID: updatedPayment.paymentID,
        );
        payment = updatedPayment.copyWith(receipt: url, paymentStatus: .submitted);
      }
      await _paymentsService.submitPaymentToAdmin(payment: payment);
      final index = _payments.indexWhere((p) => p.paymentID == payment.paymentID);
      if (index >= 0) {
        _payments[index] = payment;
      } else {
        _payments.insert(0, payment);
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      updatingPayment = false;
      notifyListeners();
    }
  }
}

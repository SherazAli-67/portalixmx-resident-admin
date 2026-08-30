import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/payment_submitted_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

class PaymentDetailProvider extends ChangeNotifier {
  PaymentDetailProvider({required this.payment}) {
    _init();
  }

  final PaymentModel payment;
  final _paymentsService = PaymentsService.instance;

  bool loading = false;
  String? error;
  List<UserModel> residents = [];
  Map<String, PaymentSubmittedModel> _submissionsByUid = {};

  PaymentSubmittedModel? submissionFor(String residentUid) => _submissionsByUid[residentUid];

  PaymentStatus statusFor(String residentUid) {
    final submission = _submissionsByUid[residentUid];
    if (submission == null) return .pending;
    return submission.approvedOnDate != null ? .received : .submitted;
  }

  Future<void> _init() async {
    loading = true;
    notifyListeners();
    try {
      UserModel? user = await UserService.instance.getCurrentUser();
      if (user == null) {
        error = "User not found";
        loading = false;
        notifyListeners();
        return;
      }
      residents = await ResidentsService.instance.loadResidentsOfSociety(societyID: user.societyID);
      await refreshSubmissions();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refreshSubmissions() async {
    try {
      final submissions = await _paymentsService.getSubmissions(paymentID: payment.paymentID);
      _submissionsByUid = {
        for (final submission in submissions) submission.paymentByUID: submission
      };
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/helpers/formating_helper.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/payment_submitted_model.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';
import '../../core/res/firebase_constant.dart';

class PaymentsService {
  static final PaymentsService _instance = PaymentsService._internal();
  factory PaymentsService() => _instance;
  PaymentsService._internal();
  static PaymentsService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getCountBySociety(String societyID) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConst.paymentsCol)
          .where('societyID', isEqualTo: societyID)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<PaymentModel>> getPayments(String societyID) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConst.paymentsCol)
          .where('societyID', isEqualTo: societyID)
          .get();
      return snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<List<PaymentModel>> watchPayments(String societyID) {
    return _firestore
        .collection(FirebaseConst.paymentsCol)
        .where('societyID', isEqualTo: societyID)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data())).toList());
  }

  Stream<int> watchCountBySociety(String societyID) {
    return _firestore
        .collection(FirebaseConst.paymentsCol)
        .where('societyID', isEqualTo: societyID)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<List<PaymentModel>> getAdminPayments(String societyID) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConst.paymentsToAdminCol)
          .where('societyID', isEqualTo: societyID)
          .get();
      return snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<PaymentModel?> addPayment({
    required String paymentFor,
    required String description,
    required String amount,
    required List<XFile> receipts,
  }) async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (user == null) throw Exception("User not found!");
      if (FormatingHelper.validatePaymentAmount(amount) != null) {
        throw Exception("Invalid payment amount");
      }
      final parsedAmount = FormatingHelper.tryParseAmount(amount);
      if (parsedAmount == null) throw Exception("Invalid payment amount");

      final now = DateTime.now().toUtc();
      final payment = PaymentModel(
        paymentID: now.toIso8601String(),
        paymentForTitle: paymentFor,
        description: description,
        amount: parsedAmount,
        societyID: user.societyID,
        paymentByUID: user.userID,
        paymentType: .paymentToAdmin,
        dateTime: now,
      );
      await _firestore.collection(FirebaseConst.paymentsCol).doc(payment.paymentID).set(payment.toMap());
      return payment;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<PaymentModel>> getUserPaymentHistory({required String userID}) async {
    try {
      final user = await UserService.instance.getUserByID(userID: userID);
      if (user == null) return [];
      final payments = await getPayments(user.societyID);
      final matches = await Future.wait(payments.map((payment) async {
        final doc = await _firestore
            .collection(FirebaseConst.paymentsCol)
            .doc(payment.paymentID)
            .collection(FirebaseConst.paymentsSubmittedCol)
            .doc(userID)
            .get();
        return doc.exists ? payment : null;
      }));
      return matches.whereType<PaymentModel>().toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<PaymentSubmittedModel>> getSubmissions({required String paymentID}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConst.paymentsCol)
          .doc(paymentID)
          .collection(FirebaseConst.paymentsSubmittedCol)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['paymentByUID'] = doc.id;
        return PaymentSubmittedModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> markResidentPaymentReceived({
    required PaymentModel payment,
    required String residentUid,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConst.paymentsCol)
          .doc(payment.paymentID)
          .collection(FirebaseConst.paymentsSubmittedCol)
          .doc(residentUid)
          .update({
            'paymentStatus': PaymentStatus.received.index,
            'approvedOnDate': DateTime.now().toUtc().toIso8601String(),
          });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> rejectResidentPaymentSubmission({
    required PaymentModel payment,
    required String residentUid,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConst.paymentsCol)
          .doc(payment.paymentID)
          .collection(FirebaseConst.paymentsSubmittedCol)
          .doc(residentUid)
          .update({'paymentStatus': PaymentStatus.rejected.index});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> uploadAdminReceipt({required XFile receipt, required String paymentID}) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('payments_to_admin/$paymentID/${receipt.name}');
    final task = await storageRef.putFile(File(receipt.path));
    return task.ref.getDownloadURL();
  }

  Future<void> submitPaymentToAdmin({required PaymentModel payment}) async {
    try {
      await _firestore
          .collection(FirebaseConst.paymentsToAdminCol)
          .doc(payment.paymentID)
          .update(payment.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updatePayment({required PaymentModel payment}) async {
    try {
      await _firestore
          .collection(FirebaseConst.paymentsCol)
          .doc(payment.paymentID)
          .set(payment.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deletePayment({required String paymentID}) async {
    try {
      await _firestore.collection(FirebaseConst.paymentsCol).doc(paymentID).delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

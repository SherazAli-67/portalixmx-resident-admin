import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/app_data/app_data.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
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
      return snapshot.docs.map((doc)=> PaymentModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<List<PaymentModel>> getAdminPayments(String societyID) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConst.paymentsToAdminCol)
          .where('societyID', isEqualTo: societyID)
          .get();

      return snapshot.docs.map((doc)=> PaymentModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<PaymentModel?> addPayment({required String paymentFor, required String description, required String amount, required List<XFile> receipts})async {
    try {
      UserModel? user = await UserService.instance.getCurrentUser();
      if(user == null) throw Exception("User not found!");

       DateTime now = .now().toUtc();
       PaymentModel payment = PaymentModel(paymentID: now.toIso8601String(),
           paymentForTitle: paymentFor,
           description: description,
           amount: amount.isNotEmpty ? double.parse(amount) : 0,
           societyID: user.societyID,
           paymentByUID: user.userID,
           paymentType: .paymentToAdmin,
           dateTime: now);
      await _firestore
          .collection(FirebaseConst.paymentsCol)
          .doc(payment.paymentID).set(payment.toMap());
      return payment;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<PaymentModel>> getUserPaymentHistory({required String userID}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConst.paymentsCol)
          .where('paymentByUID', isEqualTo: userID)
          .get();
      return snapshot.docs.map((doc)=> PaymentModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void createAdminPayments() async{
    AppData.adminPayments.forEach((payment) async {
      DocumentReference docRef =  _firestore.collection(FirebaseConst.paymentsToAdminCol).doc();
      String paymentID = docRef.id;
      await docRef.set(payment.copyWith(paymentID: paymentID).toMap());
      debugPrint("Payment #${payment.paymentID} sent");
    });
  }

  Future<void> submitPaymentToAdmin({required PaymentModel payment}) async {
    try{
      await _firestore
          .collection(FirebaseConst.paymentsToAdminCol).doc(payment.paymentID).update(payment.toMap());
    }catch(e){
      throw Exception(e.toString());
    }
  }

  Future<void> updatePayment({required PaymentModel payment, })async {
    try{
      await _firestore
          .collection(FirebaseConst.paymentsCol).doc(payment.paymentID).update(payment.toMap());
    }catch(e){
      throw Exception(e.toString());
    }

  }
}

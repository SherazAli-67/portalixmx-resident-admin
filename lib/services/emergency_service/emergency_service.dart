import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/res/firebase_constant.dart';

enum EmergencyAlertResult { success, noContacts, noReachable, failed }

class EmergencyAlertException implements Exception {
  EmergencyAlertException(this.result);
  final EmergencyAlertResult result;
}

class EmergencyService {
  static final EmergencyService instance = EmergencyService._();
  EmergencyService._();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> saveEmergencyContacts({
    required List<String> contactIds,
  }) async {
    final uid = _auth.currentUser!.uid;
    try {
      await _firestore.collection(FirebaseConst.residentAdminCol).doc(uid).set(
        {'emergencyContacts': contactIds},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw 'Failed to save emergency contacts: $e';
    }
  }

  Future<int> sendEmergencyAlert() async {
    try {
      final callable = _functions.httpsCallable('sendEmergencyAlert');
      final result = await callable.call();
      final data = result.data;
      if (data is Map) {
        final sent = data['sent'];
        if (sent is int) return sent;
        if (sent is num) return sent.toInt();
      }
      return 0;
    } on FirebaseFunctionsException catch (e) {
      throw EmergencyAlertException(_mapFunctionsError(e));
    } catch (e) {
      throw EmergencyAlertException(EmergencyAlertResult.failed);
    }
  }

  EmergencyAlertResult _mapFunctionsError(FirebaseFunctionsException e) {
    final message = e.message?.toLowerCase() ?? '';
    if (e.code == 'failed-precondition' && message.contains('no emergency contacts')) {
      return EmergencyAlertResult.noContacts;
    }
    if (e.code == 'failed-precondition' && message.contains('no reachable contacts')) {
      return EmergencyAlertResult.noReachable;
    }
    return EmergencyAlertResult.failed;
  }
}

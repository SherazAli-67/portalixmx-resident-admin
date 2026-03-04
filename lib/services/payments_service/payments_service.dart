import 'package:cloud_firestore/cloud_firestore.dart';
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/community_event_model.dart';
import '../../core/res/firebase_constant.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  static CommunityService get instance => _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getCommunityEventsCollection() {
    return _firestore
        .collection(FirebaseConst.communityCalendarEventsCol);
  }

  Future<List<CommunityEventModel>> initCommunityEvents(String societyID) async {
    try {
      final snapshot = await _getCommunityEventsCollection().where('societyID', isEqualTo: societyID).get();
      return snapshot.docs
          .map((doc) => CommunityEventModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get visitors: $e');
    }
  }


  Future<void> addUpdateEvent({required CommunityEventModel event}) async {
    try {
      await _getCommunityEventsCollection().doc(event.id).set(event.toMap());
    } catch (e) {
      throw Exception('Failed to add/update event$e');
    }
  }
}

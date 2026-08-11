import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/community_poll_model.dart';
import '../../core/res/firebase_constant.dart';

class CommunityPollsService {
  static final CommunityPollsService _instance = CommunityPollsService._internal();
  factory CommunityPollsService() => _instance;
  CommunityPollsService._internal();

  static CommunityPollsService get instance => _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getPollsCollection() {
    return _firestore.collection(FirebaseConst.communityPollsCol);
  }

  Future<List<CommunityPollModel>> getPolls(String societyID) async {
    try {
      final snapshot = await _getPollsCollection()
          .where('societyID', isEqualTo: societyID)
          .get();
      return snapshot.docs
          .map((doc) => CommunityPollModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get polls: $e');
    }
  }

  Future<void> createPoll(CommunityPollModel poll) async {
    try {
      await _getPollsCollection().doc(poll.id).set(poll.toMap());
    } catch (e) {
      throw Exception('Failed to create poll: $e');
    }
  }
}

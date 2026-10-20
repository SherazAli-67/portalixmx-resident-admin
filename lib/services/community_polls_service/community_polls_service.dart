import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
      final snapshot = await _getPollsCollection().where('societyID', isEqualTo: societyID).get();
      return snapshot.docs
          .map((doc) => CommunityPollModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get polls: $e');
    }
  }

  Future<String> uploadPollImage({required XFile image, required String pollId, required String societyID}) async {
    final storageRef = FirebaseStorage.instance.ref().child('$societyID/community_polls/$pollId/${image.name}');
    final task = await storageRef.putFile(
      File(image.path),
      SettableMetadata(contentType: _imageContentType(image.name)),
    );
    return task.ref.getDownloadURL();
  }

  String _imageContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  Future<void> createPoll(CommunityPollModel poll) async {
    try {
      await _getPollsCollection().doc(poll.id).set(poll.toMap());
    } catch (e) {
      throw Exception('Failed to create poll: $e');
    }
  }

  Future<void> updatePoll(CommunityPollModel poll) async {
    try {
      await _getPollsCollection().doc(poll.id).set(poll.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update poll: $e');
    }
  }

  Future<void> deletePoll({required String pollId}) async {
    try {
      await _getPollsCollection().doc(pollId).delete();
    } catch (e) {
      throw Exception('Failed to delete poll: $e');
    }
  }
}

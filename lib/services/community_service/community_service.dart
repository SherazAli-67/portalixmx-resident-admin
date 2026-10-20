import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/community_event_model.dart';
import '../../core/res/firebase_constant.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  static CommunityService get instance => _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getCommunityEventsCollection() {
    return _firestore.collection(FirebaseConst.communityCalendarEventsCol);
  }

  Future<List<CommunityEventModel>> initCommunityEvents(String societyID) async {
    try {
      final snapshot = await _getCommunityEventsCollection().where('societyID', isEqualTo: societyID).get();
      return snapshot.docs
          .map((doc) => CommunityEventModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  Future<String> uploadEventImage({required XFile image, required String eventId}) async {
    final storageRef = FirebaseStorage.instance.ref().child('community_events/$eventId/${image.name}');
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

  Future<void> addUpdateEvent({required CommunityEventModel event}) async {
    try {
      await _getCommunityEventsCollection().doc(event.id).set(event.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add/update event: $e');
    }
  }

  Future<void> deleteEvent({required String eventId}) async {
    try {
      await _getCommunityEventsCollection().doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}

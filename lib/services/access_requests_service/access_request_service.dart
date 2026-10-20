import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/access_model.dart';
import '../../core/models/access_request_model.dart';
import '../../core/res/firebase_constant.dart';
import '../user_service/user_service.dart';

class AccessRequestService {
  static final AccessRequestService _instance = AccessRequestService._internal();
  factory AccessRequestService() => _instance;
  AccessRequestService._internal();
  static AccessRequestService get instance => _instance;

  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _getAccessRequestsCollection =>
      _firestore.collection(FirebaseConst.accessRequestsCol);

  CollectionReference get _getAccessCollection =>
      _firestore.collection(FirebaseConst.accessCol);

  Future<AccessRequestModel> createRequest({
    required DateTime date,
    required TimeOfDay time,
    required AccessModel access,
  }) async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (user == null) throw Exception('User not found');
      final now = DateTime.now().toUtc();
      final accessRequestModel = AccessRequestModel(
        id: now.toIso8601String(),
        requestByUID: _auth.currentUser!.uid,
        requestedAccessTitle: access.name,
        requestedAccessImage: access.image,
        residentAdminID: user.userID,
        societyID: user.societyID,
        requestedForDate: date,
        requestedForTime: time,
        status: .pending,
        createdAt: now,
        updatedAt: now,
      );
      await _getAccessRequestsCollection.doc(accessRequestModel.id).set(accessRequestModel.toMap());
      return accessRequestModel;
    } catch (e) {
      throw Exception('Failed to add access request: $e');
    }
  }

  Future<List<AccessRequestModel>> getAllRequests({required String societyID}) async {
    try {
      final snapshot = await _getAccessRequestsCollection.where('societyID', isEqualTo: societyID).get();
      return snapshot.docs
          .map((doc) => AccessRequestModel.fromMap(doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get requests: $e');
    }
  }

  Future<List<AccessModel>> getAllAccessList({String? societyID}) async {
    try {
      Query query = _firestore.collection(FirebaseConst.accessCol);
      if (societyID != null && societyID.isNotEmpty) {
        query = query.where('societyID', isEqualTo: societyID);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AccessModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get access list: $e');
    }
  }

  Future<List<AccessModel>> fetchAllAccess({String? societyID}) async {
    try {
      return await getAllAccessList(societyID: societyID);
    } catch (e) {
      debugPrint("Failed to load access: ${e.toString()}");
    }
    return [];
  }

  Future<int> getCountBySociety(String societyID) async {
    try {
      final snapshot = await _getAccessRequestsCollection
          .where('societyID', isEqualTo: societyID)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> updateRequest(AccessRequestModel request) async {
    try {
      await _getAccessRequestsCollection.doc(request.id).set(request.toMap());
      debugPrint("Updated to ${request.status.name}");
    } catch (e) {
      throw Exception("Failed to update the request: ${e.toString()}");
    }
  }

  Future<String> uploadAccessImage({required XFile image, required String accessId}) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('access/$accessId/${image.name}');
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

  Future<void> addUpdateAccess({required AccessModel access}) async {
    try {
      await _getAccessCollection.doc(access.id).set(access.toJson());
    } catch (e) {
      throw Exception("Failed to add/update the access: ${e.toString()}");
    }
  }

  Future<void> deleteAccess({required String accessID}) async {
    try {
      await _getAccessCollection.doc(accessID).delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateAccess(AccessModel access) async {
    try {
      await _getAccessCollection.doc(access.id).set(access.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

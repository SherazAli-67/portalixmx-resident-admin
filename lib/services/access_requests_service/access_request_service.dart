import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/models/access_model.dart';
import '../../core/models/access_request_model.dart';
import '../../core/res/firebase_constant.dart';

class AccessRequestService {
  static final AccessRequestService _instance = AccessRequestService._internal();
  factory AccessRequestService() => _instance;
  AccessRequestService._internal();
  static AccessRequestService get instance => _instance;

  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _getAccessRequestsCollection =>
      _firestore.collection(FirebaseConst.accessRequestsCol);

  Future<AccessRequestModel> createRequest({required DateTime date, required TimeOfDay time, required AccessModel access}) async {
    try {
      DateTime now = DateTime.now().toUtc();
      AccessRequestModel accessRequestModel = AccessRequestModel(id: now.toIso8601String(),
          requestByUID: _auth.currentUser!.uid,
          requestedAccessTitle: access.name,
          requestedAccessImage: access.image,
          residentAdminID: '1',
          societyID: '1',
          requestedForDate: date,
          requestedForTime: time,
          createdAt: now,
          updatedAt: now);
      await _getAccessRequestsCollection.doc(accessRequestModel.id).set(accessRequestModel.toMap());
      return accessRequestModel;
    } catch (e) {
      throw Exception('Failed to add access request: $e');
    }
  }

  Future<List<AccessRequestModel>> getAllRequests() async {
    try {
      final snapshot = await _getAccessRequestsCollection.where('requestByUID', isEqualTo: _auth.currentUser!.uid).get();
      debugPrint("Access requests: ${snapshot.size}");
      return snapshot.docs
          .map((doc) => AccessRequestModel.fromMap(doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get requests: $e');
    }
  }
/*
  Future<void> deleteComplaintByID(String complaintID) async{
    try {
      await _getAccessRequestsCollection.doc(complaintID).delete();
    } catch (e) {
      throw Exception('Failed to add visitor: $e');
    }
  }*/

  Future<void> initAccess()async{
    List<AccessModel> accessList = [
      AccessModel(id: '1', name: 'Pool', image: 'https://cdn-icons-png.flaticon.com/512/1041/1041007.png'),
      AccessModel(id: '2', name: 'Gym', image: 'https://cdn-icons-png.flaticon.com/512/4471/4471883.png'),
      AccessModel(id: '3', name: 'Game', image: 'https://static.vecteezy.com/system/resources/thumbnails/045/493/238/small_2x/retro-yellow-pickleball-round-ball-sport-accessory-png.png'),
    ];

    for (var access in accessList) {
      await _firestore.collection(FirebaseConst.accessCol).doc(access.id).set(access.toJson());
    }
  }

  Future<List<AccessModel>> fetchAllAccess() async {
    try {
      final snapshot = await _firestore.collection(FirebaseConst.accessCol).get();
      return snapshot.docs
          .map((doc) => AccessModel.fromJson(doc.data()))
          .toList();
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
}

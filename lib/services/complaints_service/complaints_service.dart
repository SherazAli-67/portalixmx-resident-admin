import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../core/models/complaints_model.dart';
import '../../core/res/firebase_constant.dart';
import '../user_service/user_service.dart';

class ComplaintsService {
  static final ComplaintsService _instance = ComplaintsService._internal();
  factory ComplaintsService() => _instance;
  ComplaintsService._internal();
  static ComplaintsService get instance => _instance;

  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _getComplaintsCollection => _firestore.collection(FirebaseConst.complaintsCol);

  Future<ComplaintModel?> addComplaint({required String complaintText, List<String>? images}) async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (user == null) throw Exception('User not found');
      final now = DateTime.now().toUtc();
      final complaint = ComplaintModel(
        id: now.toIso8601String(),
        complaint: complaintText,
        images: images ?? [],
        complaintBy: _auth.currentUser!.uid,
        residentAdminID: user.userID,
        societyID: user.societyID,
        status: ComplaintStatus.pending,
        createdAt: now,
        updatedAt: now,
      );
      await _getComplaintsCollection.doc(complaint.id).set(complaint.toMap());
      return complaint;
    } catch (e) {
      throw Exception('Failed to create complaint request: $e');
    }
  }

  Future<List<ComplaintModel>> getAllComplaints({required String societyID}) async {
    try {
      final snapshot = await _getComplaintsCollection.where('societyID', isEqualTo: societyID).orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ComplaintModel.fromMap(doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get visitors: $e');
    }
  }

  Future<void> deleteComplaintByID(String complaintID) async{
    try {
      await _getComplaintsCollection.doc(complaintID).delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }

  Future<int> getCountBySociety(String societyID) async {
    try {
      final snapshot = await _getComplaintsCollection
          .where('societyID', isEqualTo: societyID)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> updateComplaint(ComplaintModel complaint) async{
    try {
      await _getComplaintsCollection.doc(complaint.id).set(complaint.toMap());
      debugPrint("Updated to ${complaint.status.name}");
    } catch (e) {
      throw Exception("Failed to update the complaint: ${e.toString()}");
    }
  }
}

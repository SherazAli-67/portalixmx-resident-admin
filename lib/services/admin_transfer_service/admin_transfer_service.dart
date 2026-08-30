import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/firebase_constant.dart';

class AdminTransferService {
  static final AdminTransferService instance = AdminTransferService._();
  AdminTransferService._();

  final _firestore = FirebaseFirestore.instance;

  bool canManageSociety({required String callerUid, required SocietyModel society,}) {
    final owner = society.residentAdmin;
    // debugPrint("OwnerID: $owner, and callerUID: $callerUid, SocietyID: ${society.id}");
    if (owner == null || owner.isEmpty) return true;
    return owner == callerUid;
  }

  Future<List<UserModel>> listTransferCandidates({
    required String societyID,
    required String excludeUid,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConst.residentAdminCol)
          .where('societyID', isEqualTo: societyID)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((admin) => admin.userID != excludeUid)
          .toList();
    } catch (e) {
      throw 'Failed to load transfer candidates: $e';
    }
  }

  Future<void> transferSocietyAdmin({
    required String societyID,
    required String fromUid,
    required String toUid,
  }) async {
    if (fromUid == toUid) {
      throw 'Cannot transfer ownership to yourself';
    }

    final societyRef =
        _firestore.collection(FirebaseConst.societiesCol).doc(societyID);
    final fromRef =
        _firestore.collection(FirebaseConst.residentAdminCol).doc(fromUid);
    final toRef =
        _firestore.collection(FirebaseConst.residentAdminCol).doc(toUid);

    final results = await Future.wait([
      societyRef.get(),
      fromRef.get(),
      toRef.get(),
    ]);

    final societySnap = results[0];
    final fromSnap = results[1];
    final toSnap = results[2];

    if (!societySnap.exists) {
      throw 'Society not found';
    }
    if (!fromSnap.exists) {
      throw 'Current admin not found';
    }
    if (!toSnap.exists) {
      throw 'Target admin not found';
    }

    final society =
        SocietyModel.fromMap(societySnap.data() as Map<String, dynamic>);
    final fromAdmin =
        UserModel.fromMap(fromSnap.data() as Map<String, dynamic>);
    final toAdmin = UserModel.fromMap(toSnap.data() as Map<String, dynamic>);

    if (fromAdmin.status != UserStatus.approved) {
      throw 'Only an approved admin can transfer ownership';
    }
    if (!canManageSociety(callerUid: fromUid, society: society)) {
      throw 'You are not the owner of this society';
    }
    if (toAdmin.societyID != societyID) {
      throw 'Target admin does not belong to this society';
    }

    final batch = _firestore.batch();
    batch.update(societyRef, {'residentAdmin': toUid});
    batch.update(toRef, {'status': UserStatus.approved.index});
    batch.update(fromRef, {'status': UserStatus.pending.index});
    await batch.commit();
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import '../../core/models/user_model.dart';
import '../../core/res/firebase_constant.dart';

class ResidentsService {
 
  static final ResidentsService _instance = ResidentsService._internal();
  factory ResidentsService() => _instance;
  ResidentsService._internal();
  static ResidentsService get instance => _instance;

  final _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> loadResidentsOfSociety({required String societyID}) async {
    try{
      final querySnapshot = await _firestore
          .collection(
          FirebaseConst.residentsCol)
          .where('societyID', isEqualTo: societyID).orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc)=> UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Failed to load residents: $e';
    }
  }

  Future<String?> updateUser({required UserModel user}) async{
    try{
       await _firestore.collection(FirebaseConst.residentsCol).doc(user.userID).set(user.toMap());
       return null;
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  Future<SocietyModel?> getSocietyByID({required String societyID}) async {
    try{
      DocumentSnapshot docSnap = await _firestore.collection(FirebaseConst.societiesCol).doc(societyID).get();
      if (!docSnap.exists || docSnap.data() == null) return null;
      final data = Map<String, dynamic>.from(docSnap.data() as Map);
      data['id'] = data['id'] ?? docSnap.id;
      return SocietyModel.fromMap(data);
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  Future<SocietyModel?> updateSociety({required SocietyModel society}) async {
    try{
      await _firestore.collection(FirebaseConst.societiesCol).doc(society.id).set(society.toMap());
      return null;
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  Future<String?> uploadImage({required XFile selectedImageFile, required String societyID}) async{
    try{
      if (societyID.isEmpty) {
        throw Exception('Society ID is required to upload cover image');
      }
      final contentType = _imageContentType(selectedImageFile.name);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("society_coverImage/$societyID/${selectedImageFile.name}");
      TaskSnapshot task = await storageRef.putFile(
        File(selectedImageFile.path),
        SettableMetadata(contentType: contentType),
      );
      String imageUrl = await task.ref.getDownloadURL();
      return imageUrl;
    }catch(e){
      throw Exception("Failed to upload image: ${e.toString()}");
    }
  }

  String _imageContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
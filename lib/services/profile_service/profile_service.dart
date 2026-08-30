import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_model.dart';
import '../../core/res/firebase_constant.dart';

class ProfileService {
  static final ProfileService instance =  ProfileService._();
  ProfileService._();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUser() async {
    try{
      String currentUID = _auth.currentUser!.uid;
     final docSnap = await _firestore.collection(FirebaseConst.residentAdminCol).doc(currentUID).get();
     if(docSnap.exists){
       return UserModel.fromMap(docSnap.data()!);
     }
      return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  Future<String?> updateUser({required UserModel user}) async{
    try{
      String currentUID = _auth.currentUser!.uid;
       await _firestore.collection(FirebaseConst.residentsCol).doc(currentUID).set(user.toMap());
       return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  Future<String?> uploadImage({required XFile selectedImageFile, required String userID}) async {
    try{
      final contentType = _imageContentType(selectedImageFile.name);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("resident-admin/profile_pictures/$userID/${selectedImageFile.name}");
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
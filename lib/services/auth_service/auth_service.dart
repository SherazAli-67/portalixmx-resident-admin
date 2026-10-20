import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import '../../core/models/user_model.dart';
import '../../core/res/firebase_constant.dart';

class AuthService {
  static final AuthService instance =  AuthService._();
  AuthService._();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<User?> signup({required String name, required String email, required String password, required String societyID, XFile? image}) async {
    try{
     final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
     if(userCredential.user != null){
       User authUser = userCredential.user!;
       UserModel user = UserModel(userID: authUser.uid, userName: name, email: email, createdAt: DateTime.now().toUtc(), societyID: societyID);
       final userMap = user.toMap();
       try {
         final fcmToken = await FirebaseMessaging.instance.getToken();
         if (fcmToken != null) {
           userMap['token'] = fcmToken;
         }
       } catch (_) {}
       await _firestore.collection(FirebaseConst.residentAdminCol).doc(user.userID).set(userMap);
       await _claimSocietyAdminIfEmpty(societyID: societyID, adminUid: user.userID);
       if (image != null) {
         final profilePicture = await updateProfilePicture(image);
         if (profilePicture != null) {
           await _firestore.collection(FirebaseConst.residentAdminCol).doc(user.userID).update({
             'profileImg': profilePicture,
           });
         }
       }
       return authUser;
     }
     return null;
    }on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Failed to sign up: $e';
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password,);
      if(userCredential.user != null) {
        DocumentSnapshot docSnap = await _firestore.collection(
            FirebaseConst.residentAdminCol).doc(userCredential.user!.uid).get();
        return UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Failed to sign in: $e';
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user corresponding to the given email has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-credential':
        return 'The provided email or password is invalid.';
      case 'requires-recent-login':
        return 'requires-recent-login';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> deleteAccount() async {
    try{
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection(FirebaseConst.residentsCol).doc(currentUID).delete();

      await _auth.currentUser!.delete();
      return null;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        rethrow;
      }
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      final email = user.email;
      if (email == null) {
        throw 'User email is not available';
      }

      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Failed to re-authenticate: $e';
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try{
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
     final docSnap = await _firestore.collection(FirebaseConst.residentsCol).doc(currentUID).get();
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
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
       await _firestore.collection(FirebaseConst.residentsCol).doc(currentUID).set(user.toMap());
       return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  Future<List<SocietyModel>> getSocieties() async {
    try {
      final callable = _functions.httpsCallable('listSocietiesForSignup');
      final result = await callable.call();
      final data = result.data;
      final rawList = data is Map ? data['societies'] : null;
      if (rawList is! List) {
        return [];
      }
      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return SocietyModel.fromMap(map);
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'Failed to load societies';
    } catch (e) {
      throw 'Failed to load societies: $e';
    }
  }
  Future<SocietyModel?> getSociety() async {
    try{
      UserModel? user = await getCurrentUser();
      if(user == null) throw Exception('User not found');
      DocumentSnapshot docSnap = await _firestore.collection(FirebaseConst.societiesCol).doc(user.societyID).get();
      return SocietyModel.fromMap(docSnap.data() as Map<String, dynamic>);
    } catch (e) {
      throw 'Failed to get society: $e';
    }
  }

  Future<String?> updateProfilePicture(XFile image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user for profile image upload');
      }
      await user.getIdToken(true);
      try {
        final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
        if (appCheckToken == null || appCheckToken.isEmpty) {
          throw Exception('App Check token unavailable');
        }
      } catch (e) {
        throw Exception(
          'App Check token unavailable. Register this device debug token in Firebase Console → App Check → Manage debug tokens. $e',
        );
      }
      final contentType = _imageContentType(image.name);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("resident-admin/profile_pictures/${user.uid}/${image.name}");
      TaskSnapshot task = await storageRef.putFile(
        File(image.path),
        SettableMetadata(contentType: contentType),
      );
      String imageUrl = await task.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
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

  Future<void> _claimSocietyAdminIfEmpty({
    required String societyID,
    required String adminUid,
  }) async {
    final societyRef =
        _firestore.collection(FirebaseConst.societiesCol).doc(societyID);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(societyRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final currentAdmin = data['residentAdmin'] as String?;
      if (currentAdmin == null || currentAdmin.isEmpty) {
        transaction.update(societyRef, {'residentAdmin': adminUid});
      }
    });
  }
}
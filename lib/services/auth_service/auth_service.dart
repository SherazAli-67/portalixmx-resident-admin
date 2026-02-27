import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';
import '../../core/res/firebase_constant.dart';

class AuthService {
  static final AuthService instance =  AuthService._();
  AuthService._();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> signup({required String name, required String email, required String password})async{
    try{
     final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
     if(userCredential.user != null){
       User authUser = userCredential.user!;
       UserModel user = UserModel(userID: authUser.uid, userName: name, email: email, createdAt: DateTime.now().toUtc());
       await _firestore.collection(FirebaseConst.residentsCol).doc(user.userID).set(user.toMap());
       return authUser;
     }
     return null;
    }on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Failed to sign up: $e';
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password,);
      return userCredential.user;
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
}
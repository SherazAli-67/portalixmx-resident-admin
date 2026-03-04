import 'package:cloud_firestore/cloud_firestore.dart';
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
      final querySnapshot = await _firestore.collection(FirebaseConst.residentsCol).where('societyID', isEqualTo: societyID).get();
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
      return SocietyModel.fromMap(docSnap.data() as Map<String, dynamic>);
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }
}
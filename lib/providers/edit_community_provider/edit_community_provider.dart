import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

class EditUpdateCommunityProvider extends ChangeNotifier{
  final _residentService = ResidentsService.instance;
  bool loadingSociety = false;
  String? error;
  SocietyModel? society;

  bool updatingSociety = false;

  EditUpdateCommunityProvider(){
    _initSocietyInfo();
  }


  void _initSocietyInfo()async {
    loadingSociety = true;
    notifyListeners();
    try{
     UserModel? user=  await UserService.instance.getCurrentUser();
     if(user == null){
       error = "User not found";
       society = null;
     } else {
       society = await _residentService.getSocietyByID(societyID: user.societyID);
     }
    }catch(e){
      error = e.toString();
    } finally {
      loadingSociety = false;
      notifyListeners();
    }
  }

  Future<String?> updateSociety({required String name, required String address}) async {
    updatingSociety = true;
    notifyListeners();
    try{
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null) throw Exception("User not found");

      society = await _residentService.updateSociety(society: society!.copyWith(name: name, location: address));
      updatingSociety = false;
      notifyListeners();
      return null;
    }catch(e){
      return e.toString();
    } finally {
      updatingSociety = false;
      notifyListeners();
    }
  }
}
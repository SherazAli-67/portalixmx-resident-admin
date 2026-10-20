import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

import '../core/models/user_model.dart';

class CommunityDirectoryProvider extends ChangeNotifier{
  bool loadingResidents = false;

  final _userService = UserService.instance;
  final _residentsService = ResidentsService.instance;
  List<UserModel> residents = [];

  CommunityDirectoryProvider(){
    _initCommunityMembers();
  }

  void _initCommunityMembers() async{
    try {
      loadingResidents = true;
      notifyListeners();

      UserModel? user = await _userService.getCurrentUser();
      if(user == null) throw Exception("No resident admin found");
      residents = await _residentsService.loadResidentsOfSociety(societyID: user.societyID);
      loadingResidents = false;
      notifyListeners();
    } catch (e) {
      loadingResidents = false;
      notifyListeners();
      debugPrint("Exception while loading residents: ${e.toString()}");
    }
  }
}
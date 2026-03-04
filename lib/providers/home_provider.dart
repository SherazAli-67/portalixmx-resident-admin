import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/services/access_requests_service/access_request_service.dart';
import 'package:portalixmx_resident_admin/services/complaints_service/complaints_service.dart';
import 'package:portalixmx_resident_admin/services/payments_service/payments_service.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import '../core/models/user_model.dart';
import '../services/user_service/user_service.dart';

class HomeProvider extends ChangeNotifier {

  final _userService = UserService.instance;
  final _residentsService = ResidentsService.instance;
  final _paymentsService = PaymentsService.instance;
  final _complaintsService = ComplaintsService.instance;
  final _accessRequestService = AccessRequestService.instance;
  UserStatus _selectedTab = .approved;
  UserStatus get selectedTab => _selectedTab;

  bool loading = false;
  bool loadingResidents = false;
  bool loadingOverview = false;
  bool updatingResidentStatus = false;
  List<UserModel> _residents = [];
  SocietyModel? _society;
  int _totalPayments = 0;
  int _totalComplaints = 0;
  int _totalAccessRequests = 0;
  List<UserModel> get residents => _residents.where((resident)=> resident.status == _selectedTab).toList();
  SocietyModel? get society => _society;
  int get totalResidents => _residents.length;
  int get totalPayments => _totalPayments;
  int get totalComplaints => _totalComplaints;
  int get totalAccessRequests => _totalAccessRequests;


  Future<UserModel?> getCurrentUser() async {
    try {
      UserModel? user = await _userService.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  HomeProvider(){
    initSociety();
    loadResidentsOfTheSociety();
    loadOverviewCounts();
  }

  Future<void> loadOverviewCounts() async {
    try {
      UserModel? user = await _userService.getCurrentUser();
      if (user == null) return;
      loadingOverview = true;
      notifyListeners();
      final results = await Future.wait([
        _paymentsService.getCountBySociety(user.societyID),
        _complaintsService.getCountBySociety(user.societyID),
        _accessRequestService.getCountBySociety(user.societyID),
      ]);
      _totalPayments = results[0];
      _totalComplaints = results[1];
      _totalAccessRequests = results[2];
    } catch (e) {
      debugPrint("Exception while loading overview counts: ${e.toString()}");
    } finally {
      loadingOverview = false;
      notifyListeners();
    }
  }

  void onTabChange(UserStatus status) {
    _selectedTab = status;
    notifyListeners();
  }

  Future<void> loadResidentsOfTheSociety() async {
    try {
      loadingResidents = true;
      notifyListeners();

      UserModel? user = await _userService.getCurrentUser();
      if(user == null) throw Exception("No resident admin found");

      _residents = await _residentsService.loadResidentsOfSociety(societyID: user.societyID);
      loadingResidents = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Exception while loading residents: ${e.toString()}");
    }
  }

  Future<void> initSociety() async {
    UserModel? user = await _userService.getCurrentUser();
    if(user == null) throw Exception("No resident admin found");

    _society = await _residentsService.getSocietyByID(societyID: user.societyID);
    notifyListeners();
  }


  Future<void> updateResident(UserModel updatedUser)async{
    updatingResidentStatus = true;
    notifyListeners();
    try {
      
      await _residentsService.updateUser(user: updatedUser);
      int index = _residents.indexWhere((resident)=> resident.userID == updatedUser.userID);
      _residents[index] = updatedUser;
      updatingResidentStatus = false;
      notifyListeners();
    } catch (e) {
      updatingResidentStatus = false;
      notifyListeners();
      debugPrint("Exception while updating resident: ${e.toString()}");
    }
  }
}
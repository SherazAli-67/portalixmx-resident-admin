import 'package:flutter/cupertino.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

import '../../l10n/app_localizations.dart';

class ResidentsProvider extends ChangeNotifier{
  final _residentsService = ResidentsService.instance;
  bool loadingResident = false;
  bool loadingSociety = false;
  String? error;

  List<UserModel> residents = [];
  SocietyModel? society;


  String? selectedFilter;
  String? selectedPaymentStatusFilter;

  ResidentsProvider(){
    _initSociety();
    _initResidents();
  }

  void _initSociety()async {
    loadingSociety = true;
    notifyListeners();

    try{
      UserModel? user = await UserService.instance.getCurrentUser();
      if(user == null) throw Exception("User not found");
      society = await _residentsService.getSocietyByID(societyID: user.societyID);

    }catch(e){
      error = e.toString();
      notifyListeners();
    }
    loadingSociety = false;
    notifyListeners();

  }

  void _initResidents() async{
    loadingResident = true;
    notifyListeners();

    try{
      UserModel? user = await UserService.instance.getCurrentUser();
      if(user == null) throw Exception("User not found");
      residents = await _residentsService.loadResidentsOfSociety(societyID: user.societyID);

    }catch(e){
      error = e.toString();
      notifyListeners();
    }
    loadingResident = false;
    notifyListeners();

  }


  List<String> getFilterList(AppLocalizations localization){
    return [
      localization.all,
      localization.week,
      localization.month,
      localization.year
    ];
  }

  List<String> getStatusList(AppLocalizations localization){
    return [
      localization.pending,
      localization.approved,
    ];
  }

  List<UserModel> getFilteredResidents(AppLocalizations l10n) {
    DateTime? dateCutoff;
    if (selectedFilter != null && selectedFilter != l10n.all) {
      if (selectedFilter == l10n.week) {
        dateCutoff = DateTime.now().subtract(const Duration(days: 7));
      } else if (selectedFilter == l10n.month) {
        dateCutoff = DateTime.now().subtract(const Duration(days: 30));
      } else if (selectedFilter == l10n.year) {
        dateCutoff = DateTime.now().subtract(const Duration(days: 365));
      }
    }

    UserStatus? statusFilter;
    if (selectedPaymentStatusFilter == l10n.pending) {
      statusFilter = UserStatus.pending;
    } else if (selectedPaymentStatusFilter == l10n.approved) {
      statusFilter = UserStatus.approved;
    }

    return residents.where((resident) {
      if (dateCutoff != null && resident.createdAt.isBefore(dateCutoff)) {
        return false;
      }
      if (statusFilter != null && resident.status != statusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void onChangeFilterTap(String val){
    selectedFilter = val;
    notifyListeners();
  }

  void onChangeStatusFilterTap(String val){
    selectedPaymentStatusFilter = val;
    notifyListeners();
  }
}
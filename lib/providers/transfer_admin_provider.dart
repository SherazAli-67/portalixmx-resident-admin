import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/services/admin_transfer_service/admin_transfer_service.dart';
import 'package:portalixmx_resident_admin/services/auth_service/auth_service.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

class TransferAdminProvider extends ChangeNotifier {
  final _transferService = AdminTransferService.instance;
  final _residentsService = ResidentsService.instance;
  final _userService = UserService.instance;
  final _authService = AuthService.instance;

  bool loading = false;
  bool transferring = false;
  String? error;
  SocietyModel? society;
  UserModel? currentAdmin;
  List<UserModel> candidates = [];
  UserModel? selectedCandidate;

  bool get isOwner {
    if (currentAdmin == null || society == null) return false;
    return _transferService.canManageSociety(
      callerUid: currentAdmin!.userID,
      society: society!,
    );
  }

  TransferAdminProvider() {
    _init();
  }

  Future<void> _init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      currentAdmin = await _userService.getCurrentUser();
      if (currentAdmin == null) {
        error = 'User not found';
        return;
      }
      society = await _residentsService.getSocietyByID(
        societyID: currentAdmin!.societyID,
      );
      if (society == null) {
        error = 'Society not found';
        return;
      }
      if (!isOwner) {
        error = 'not_owner';
        return;
      }
      candidates = await _transferService.listTransferCandidates(
        societyID: currentAdmin!.societyID,
        excludeUid: currentAdmin!.userID,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void selectCandidate(UserModel candidate) {
    selectedCandidate = candidate;
    notifyListeners();
  }

  Future<String?> transferOwnership() async {
    if (currentAdmin == null || selectedCandidate == null || society == null) {
      return 'Please select an admin';
    }
    transferring = true;
    notifyListeners();
    try {
      await _transferService.transferSocietyAdmin(
        societyID: currentAdmin!.societyID,
        fromUid: currentAdmin!.userID,
        toUid: selectedCandidate!.userID,
      );
      await _authService.signOut();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      transferring = false;
      notifyListeners();
    }
  }
}

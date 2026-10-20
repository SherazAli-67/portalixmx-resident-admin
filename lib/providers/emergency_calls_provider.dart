import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/select_emergency_contacts_bottomsheet.dart';
import 'package:portalixmx_resident_admin/services/emergency_service/emergency_service.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

class EmergencyCallsProvider extends ChangeNotifier {
  EmergencyCallsProvider() {
    _init();
  }

  final _emergencyService = EmergencyService.instance;
  final _residentsService = ResidentsService.instance;
  final _userService = UserService.instance;

  bool loading = false;
  bool saving = false;
  bool sending = false;
  String? error;
  UserModel? currentUser;
  List<UserModel> residents = [];
  List<String> _contactIds = [];

  List<UserModel> get contacts {
    final byId = {for (final resident in residents) resident.userID: resident};
    return _contactIds
        .map((id) => byId[id])
        .whereType<UserModel>()
        .toList();
  }

  List<UserModel> get pickerResidents {
    final uid = currentUser?.userID;
    return residents.where((resident) => resident.userID != uid).toList();
  }

  Future<void> _init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      currentUser = await _userService.getCurrentUser();
      if (currentUser == null) {
        error = 'User not found';
        return;
      }
      _contactIds = List<String>.from(currentUser!.emergencyContacts);
      residents = await _residentsService.loadResidentsOfSociety(
        societyID: currentUser!.societyID,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool?> onAddContactsTap(BuildContext context) async {
    if (saving) return null;
    final result = await BottomSheetHelper.showAdjustableModalBottomSheet<List<String>>(
      context: context,
      initialChildSize: 0.75,
      child: SelectEmergencyContactsBottomSheet(
        residents: pickerResidents,
        initiallySelectedIds: _contactIds,
      ),
    );
    if (result == null) return null;
    return _persistContacts(result);
  }

  Future<bool> removeContact(String userID) async {
    if (saving) return false;
    final updated = _contactIds.where((id) => id != userID).toList();
    return _persistContacts(updated);
  }

  Future<bool> _persistContacts(List<String> ids) async {
    if (currentUser == null) return false;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _emergencyService.saveEmergencyContacts(contactIds: ids);
      _contactIds = ids;
      currentUser = currentUser!.copyWith(emergencyContacts: ids);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<EmergencyAlertResult> sendAlert() async {
    if (sending) return EmergencyAlertResult.failed;
    if (_contactIds.isEmpty) return EmergencyAlertResult.noContacts;
    sending = true;
    notifyListeners();
    try {
      await _emergencyService.sendEmergencyAlert();
      return EmergencyAlertResult.success;
    } on EmergencyAlertException catch (e) {
      return e.result;
    } catch (_) {
      return EmergencyAlertResult.failed;
    } finally {
      sending = false;
      notifyListeners();
    }
  }
}

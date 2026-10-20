import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/add_access_bottomsheet.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/main_menu.dart';
import '../core/models/access_model.dart';
import '../core/models/access_request_model.dart';
import '../core/models/user_model.dart';
import '../core/res/app_colors.dart';
import '../services/access_requests_service/access_request_service.dart';
import '../services/user_service/user_service.dart';
import 'datetime_format_helpers.dart';

class RequestAccessProvider extends ChangeNotifier {
  final _requestsService = AccessRequestService.instance;
  bool addingRequestAccess = false;
  bool loadingRequests = false;
  bool loadingAccess = false;
  bool updatingRequest = false;
  bool addingAccess = false;
  String? error;

  List<AccessRequestModel> _allAccessRequests = [];
  List<AccessModel> _allAccess = [];

  final List<String> _filters = ['Access Requests', 'Access'];
  String _selectedFilter = 'Access Requests';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<AccessRequestModel> get allAccessRequests => _allAccessRequests;
  List<AccessRequestModel> get filteredAccessRequests {
    return _allAccessRequests.where((request) {
      return DateTimeFormatHelpers.isInInclusiveDateRange(request.createdAt, _dateFrom, _dateTo);
    }).toList();
  }
  List<AccessModel> get allAccessItems => _allAccess;
  List<String> get filters => _filters;
  String get selectedFilter => _selectedFilter;
  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;

  RequestAccessProvider() {
    _initRequests();
    _initAccess();
  }

  Future<void> _initRequests() async {
    try {
      loadingRequests = true;
      notifyListeners();
      final user = await UserService.instance.getCurrentUser();
      if (user == null) {
        error = "User not found";
        loadingRequests = false;
        notifyListeners();
        return;
      }
      _allAccessRequests = await _requestsService.getAllRequests(societyID: user.societyID);
      _allAccessRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('RequestAccessProvider: failed to fetch access items: $e');
    }
    loadingRequests = false;
    notifyListeners();
  }

  Future<void> _initAccess() async {
    try {
      loadingAccess = true;
      notifyListeners();
      final user = await UserService.instance.getCurrentUser();
      if (user == null) {
        error = "User not found";
        loadingAccess = false;
        notifyListeners();
        return;
      }
      _allAccess = await _requestsService.getAllAccessList(societyID: user.societyID);
    } catch (e) {
      debugPrint('RequestAccessProvider: failed to fetch access items: $e');
    }
    loadingAccess = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([_initRequests(), _initAccess()]);
  }

  void onAddRequestTap() async {}

  void onFilterUpdated(dynamic val) {
    _selectedFilter = val;
    notifyListeners();
  }

  void onDateFromChanged(DateTime? date) {
    _dateFrom = date;
    notifyListeners();
  }

  void onDateToChanged(DateTime? date) {
    _dateTo = date;
    notifyListeners();
  }

  Future<UserModel?> getUserByID({required String userID}) async {
    try {
      return await UserService.instance.getUserByID(userID: userID);
    } catch (e) {
      return null;
    }
  }

  void updateRequestStatus({required AccessRequestModel request}) async {
    try {
      updatingRequest = true;
      notifyListeners();
      final updated = request.copyWith(updatedAt: DateTime.now().toUtc());
      await _requestsService.updateRequest(updated);
      final index = _allAccessRequests.indexWhere((item) => item.id == updated.id);
      if (index >= 0) {
        _allAccessRequests[index] = updated;
      } else {
        _allAccessRequests.insert(0, updated);
      }
      onFilterUpdated(_selectedFilter);
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
    updatingRequest = false;
    notifyListeners();
  }

  Color getColorByStatus(RequestStatus status) {
    switch (status) {
      case .pending:
        return AppColors.btnColor;
      case .approved:
        return Colors.green;
      case .rejected:
        return Colors.red;
    }
  }

  Future<AccessModel?> onAddAccessTap({AccessModel? existing}) async {
    final result = await BottomSheetHelper.showDraggableBottomSheet(
      scaffoldKey: scaffoldKey,
      child: AddAccessBottomSheet(existingAccess: existing),
      initialHeight: 0.6
    );
    if (result == null) return null;

    final accessTitle = result['access'] as String;
    final imageFile = result['image'] as XFile?;
    final existingImageUrl = result['existingImageUrl'] as String?;
    final freeToUse = result['freeToUse'] as bool? ?? false;

    error = null;
    addingAccess = true;
    notifyListeners();
    try {
      final user = await UserService.instance.getCurrentUser();
      if (user == null) throw Exception('User not found');

      final accessId = existing?.id ?? DateTime.now().toUtc().toIso8601String();
      String imageUrl = existingImageUrl ?? existing?.image ?? '';
      if (imageFile != null) {
        imageUrl = await _requestsService.uploadAccessImage(image: imageFile, accessId: accessId);
      }

      final accessModel = AccessModel(
        id: accessId,
        name: accessTitle,
        image: imageUrl,
        freeToUse: freeToUse,
        societyID: user.societyID,
      );

      if (existing != null) {
        await _requestsService.updateAccess(accessModel);
        final index = _allAccess.indexWhere((item) => item.id == accessId);
        if (index >= 0) {
          _allAccess[index] = accessModel;
        } else {
          _allAccess.add(accessModel);
        }
      } else {
        await _requestsService.addUpdateAccess(access: accessModel);
        _allAccess.add(accessModel);
      }
      return accessModel;
    } catch (e) {
      debugPrint("Error while creating access: ${e.toString()}");
      error = e.toString();
      return null;
    } finally {
      addingAccess = false;
      notifyListeners();
    }
  }

  void onDeleteAccessTap({required AccessModel access}) async {
    try {
      _allAccess.remove(access);
      notifyListeners();
      await _requestsService.deleteAccess(accessID: access.id);
    } catch (e) {
      debugPrint("Error while deleting access: ${e.toString()}");
    }
  }

  void onToggleFreeToUseAccess(AccessModel access) async {
    try {
      final updated = access.copyWith(freeToUse: !access.freeToUse);
      final index = _allAccess.indexWhere((item) => item.id == access.id);
      if (index >= 0) _allAccess[index] = updated;
      notifyListeners();
      await _requestsService.updateAccess(updated);
    } catch (e) {
      debugPrint("Error while updating access: ${e.toString()}");
    }
  }

  void onEditAccessTap(AccessModel access) => onAddAccessTap(existing: access);
}

import 'package:flutter/material.dart';
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
  bool addingRequestAccess =  false;
  bool loadingRequests = false;
  bool loadingAccess = false;
  bool updatingRequest = false;
  bool addingAccess = false;
  String? error;

  List<AccessRequestModel> _allAccessRequests  = [];
  List<AccessModel> _allAccess  = [];

  final List<String> _filters = ['Access Requests', 'Access',];
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
  RequestAccessProvider(){
    _initRequests();
    _initAccess();
  }

  Future<void> _initRequests() async {
    try {
      loadingRequests = true;
      notifyListeners();
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
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
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
        error = "User not found";
        return;
      }
      _allAccess = await _requestsService.getAllAccessList();
    } catch (e) {
      debugPrint('RequestAccessProvider: failed to fetch access items: $e');
    }
    loadingAccess = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([_initRequests(), _initAccess()]);
  }

  void onAddRequestTap() async{

  }

  void onFilterUpdated(dynamic val){
    _selectedFilter = val;
    notifyListeners();
  }

  void onDateFromChanged(DateTime? date){
    _dateFrom = date;
    notifyListeners();
  }

  void onDateToChanged(DateTime? date){
    _dateTo = date;
    notifyListeners();
  }

  Future<UserModel?> getUserByID({required String userID}) async {
    try{
      return await UserService.instance.getUserByID(userID: userID);
    }catch(e){
      return null;
    }
  }

  void updateRequestStatus({required AccessRequestModel request})async {
    try{
      updatingRequest = true;
      notifyListeners();
      await _requestsService.updateRequest(request);
      int index = _allAccessRequests.indexWhere((item)=> item.id == request.id);
      _allAccessRequests[index] = request;
      onFilterUpdated(_selectedFilter);
      notifyListeners();
    }catch(e){
      debugPrint("Exception: ${e.toString()}");
      return null;
    }
    updatingRequest = false;
    notifyListeners();
  }

  Color getColorByStatus(RequestStatus status) {
    switch(status){
      case .pending:
        return AppColors.btnColor;
      case .approved:
        return Colors.green;
      case .rejected:
        return Colors.red;
    }
  }

  void onAddAccessTap() async{
    final result = await BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: AddAccessBottomSheet());
    if(result != null){
      String accessTitle = result['access'];
      String imagePath = result['image'];
      bool freeToUse = result['freeToUse'];

      DateTime now = DateTime.now().toUtc();
      AccessModel accessModel = AccessModel(id: now.toIso8601String(), name: accessTitle, image: imagePath, freeToUse: freeToUse);
      try{
        _allAccess.add(accessModel);
        notifyListeners();
        addingAccess = true;
        notifyListeners();
       await _requestsService.addUpdateAccess(access: accessModel);
      }catch(e){
        debugPrint("Error while creating access: ${e.toString()}");
      }
      addingAccess = true;
      notifyListeners();
    }
  }

  void onDeleteAccessTap({required AccessModel access}) async{
    try{
      _allAccess.remove(access);
      notifyListeners();
      await _requestsService.deleteAccess(accessID: access.id);
    }catch(e){
      debugPrint("Error while deleting access: ${e.toString()}");
    }
    addingAccess = true;
    notifyListeners();
  }

  void onToggleFreeToUseAccess(AccessModel access) async{
    try{
      int index = _allAccess.indexWhere((item) => item.id == access.id);
      _allAccess[index] = access.copyWith(freeToUse:  !access.freeToUse);
      await _requestsService.updateAccess(access.copyWith(freeToUse: !access.freeToUse));
    }catch(e){
      debugPrint("Error while deleting access: ${e.toString()}");
    }
    addingAccess = true;
    notifyListeners();
  }
}
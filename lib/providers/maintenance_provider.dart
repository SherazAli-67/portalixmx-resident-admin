import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../core/helpers/bottom_sheet_helper.dart';
import '../core/models/complaints_model.dart';
import '../core/models/user_model.dart';
import '../presentation/bottomsheets/add_complaint_bottomsheet.dart';
import '../presentation/screens/main_menu/main_menu.dart';
import '../router/app_router.dart';
import '../services/complaints_service/complaints_service.dart';
import '../services/user_service/user_service.dart';

class ComplaintDateGroup {
  final DateTime date;
  final List<ComplaintModel> complaints;

  ComplaintDateGroup({required this.date, required this.complaints});
}

class MaintenanceProvider extends ChangeNotifier {
  bool addingComplaint =  false;
  bool loadingComplaints = false;
  List<ComplaintModel> _allComplaints  = [];
  List<ComplaintModel> _filteredComplaints  = [];

  final List<String> _filters = ['All', 'Week', 'Month',];
  String _selectedFilter = 'All';
  String? error;
  final _complaintService = ComplaintsService.instance;
  List<ComplaintModel> get allComplaints => _allComplaints;
  List<ComplaintModel> get filteredComplaints => _filteredComplaints;
  List<String> get filters => _filters;
  String get selectedFilter => _selectedFilter;

  List<ComplaintDateGroup> get complaintsGroupedByDate {
    final map = <DateTime, List<ComplaintModel>>{};
    for (final c in _filteredComplaints) {
      final date = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      map.putIfAbsent(date, () => []).add(c);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    final groups = map.entries
        .map((e) => ComplaintDateGroup(date: e.key, complaints: e.value))
        .toList();
    groups.sort((a, b) => b.date.compareTo(a.date));
    return groups;
  }

  int get groupedComplaintItemCount {
    return complaintsGroupedByDate.fold<int>(
      0,
      (sum, g) => sum + 1 + g.complaints.length,
    );
  }

  bool updatingComplaint = false;

  MaintenanceProvider(){
    _initComplaints();
  }

  Future<String?> onAddComplaintTap()async{
    final result = await BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: AddComplaintBottomSheet(),);
    if(result != null){
      addingComplaint = true;
      notifyListeners();

      String complaintText = result['complaint'];
      List<XFile> complaintFiles = result['files'];

      if(complaintFiles.isNotEmpty){
      }

      try{
        ComplaintModel? complaint = await _complaintService.addComplaint(complaintText: complaintText,);
        if(complaint != null){
          _allComplaints.add(complaint);
        }
        addingComplaint = true;
        notifyListeners();
      }catch(e){
        return e.toString();
      }
    }

    return null;
  }

  Future<void> _initComplaints() async {
    try{
      loadingComplaints = true;
      notifyListeners();
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
        error = "User not found";
        return;
      }
      _allComplaints = await _complaintService.getAllComplaints(societyID: user.societyID);
      _filteredComplaints.addAll(_allComplaints);
      notifyListeners();
    }catch(e){
      debugPrint("Error while fetching complaints: ${e.toString()}");
    }

    loadingComplaints = false;
    notifyListeners();

  }

  Future<void> refreshComplaints() async {
    try {
      UserModel? user = await UserService.instance.getCurrentUser();
      if (user == null) {
        error = "User not found";
        notifyListeners();
        return;
      }
      _allComplaints = await _complaintService.getAllComplaints(societyID: user.societyID);
      onFilterUpdated(_selectedFilter);
      notifyListeners();
    } catch (e) {
      debugPrint("Error while refreshing complaints: ${e.toString()}");
      notifyListeners();
    }
  }

  void onFilterUpdated(dynamic val){
    _selectedFilter = val;
    if(_selectedFilter == 'All'){
      _filteredComplaints = _allComplaints;
    }else if(_selectedFilter == 'Week'){
      _filteredComplaints = _getComplaintsOfCurrentWeek();
    }else{
      _filteredComplaints = _getComplaintsOfCurrentMonth();
    }
    notifyListeners();
  }

  List<ComplaintModel> _getComplaintsOfCurrentWeek() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final start = end.subtract(const Duration(days: 7));

    return _allComplaints.where((complaint) {
      return complaint.createdAt.isAfter(start) &&
          complaint.createdAt.isBefore(end);
    }).toList();
  }

  List<ComplaintModel> _getComplaintsOfCurrentMonth() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 1)
        : DateTime(now.year + 1, 1, 1);

    return _allComplaints.where((complaint) {
      return complaint.createdAt.isAfter(start) &&
          complaint.createdAt.isBefore(end);
    }).toList();
  }

  Future<UserModel?> getUserByID({required String userID}) async {
    try{
     return await UserService.instance.getUserByID(userID: userID);
    }catch(e){
      return null;
    }
  }

  void updateComplaintStatus({required ComplaintModel complaint}) async{
    try{
      updatingComplaint = true;
      notifyListeners();
      await _complaintService.updateComplaint(complaint);
      int index = _allComplaints.indexWhere((item)=> item.id == complaint.id);
      _allComplaints[index] = complaint;
      onFilterUpdated(_selectedFilter);
      notifyListeners();
    }catch(e){
      debugPrint("Exception: ${e.toString()}");
      return null;
    }
    updatingComplaint = false;
    notifyListeners();
  }

  void onComplaintTap(BuildContext context, {required ComplaintModel complaint}) async{
    final result = await context.push(NamedRoutes.complaintSummary.routeName, extra: complaint);
    if(result != null){
      ComplaintStatus status = result as ComplaintStatus;
      updateComplaintStatus(complaint: complaint.copyWith(status: status));
    }
  }
}
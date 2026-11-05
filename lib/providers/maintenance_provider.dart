import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/models/complaints_model.dart';
import '../core/models/user_model.dart';
import '../router/app_router.dart';
import '../services/complaints_service/complaints_service.dart';
import '../services/user_service/user_service.dart';
import 'datetime_format_helpers.dart';

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

  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? error;
  final _complaintService = ComplaintsService.instance;
  StreamSubscription<List<ComplaintModel>>? _complaintsSub;
  List<ComplaintModel> get allComplaints => _allComplaints;
  List<ComplaintModel> get filteredComplaints => _filteredComplaints;
  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;

  List<ComplaintDateGroup> get complaintsGroupedByDate {
    final map = <DateTime, List<ComplaintModel>>{};
    for (final c in _filteredComplaints) {
      final local = c.createdAt.toLocal();
      final date = DateTime(local.year, local.month, local.day);
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

  Future<void> _initComplaints() async {
    try{
      loadingComplaints = true;
      notifyListeners();
      UserModel? user=  await UserService.instance.getCurrentUser();
      if(user == null){
        error = "User not found";
        loadingComplaints = false;
        notifyListeners();
        return;
      }
      _complaintsSub?.cancel();
      _complaintsSub = _complaintService.watchComplaints(societyID: user.societyID).listen(
        (list) {
          _allComplaints = list;
          _applyDateFilter();
          loadingComplaints = false;
        },
        onError: (e) {
          debugPrint("Error while watching complaints: ${e.toString()}");
          loadingComplaints = false;
          notifyListeners();
        },
      );
    }catch(e){
      debugPrint("Error while fetching complaints: ${e.toString()}");
      loadingComplaints = false;
      notifyListeners();
    }
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
      _applyDateFilter();
    } catch (e) {
      debugPrint("Error while refreshing complaints: ${e.toString()}");
      notifyListeners();
    }
  }

  void onDateFromChanged(DateTime? date){
    _dateFrom = date;
    _applyDateFilter();
  }

  void onDateToChanged(DateTime? date){
    _dateTo = date;
    _applyDateFilter();
  }

  void _applyDateFilter(){
    _filteredComplaints = _allComplaints.where((complaint) {
      return DateTimeFormatHelpers.isInInclusiveDateRange(complaint.createdAt, _dateFrom, _dateTo);
    }).toList();
    notifyListeners();
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
      if (index >= 0) {
        _allComplaints[index] = complaint;
      }
      _applyDateFilter();
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

  @override
  void dispose() {
    _complaintsSub?.cancel();
    super.dispose();
  }
}

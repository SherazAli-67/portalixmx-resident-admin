import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../core/helpers/bottom_sheet_helper.dart';
import '../core/models/complaints_model.dart';
import '../presentation/bottomsheets/add_complaint_bottomsheet.dart';
import '../presentation/screens/main_menu/main_menu.dart';
import '../services/complaints_service/complaints_service.dart';

class MaintenanceProvider extends ChangeNotifier {
  bool addingComplaint =  false;
  bool loadingComplaints = false;
  List<ComplaintModel> _allComplaints  = [];
  List<ComplaintModel> _filteredComplaints  = [];

  final List<String> _filters = ['All', 'Week', 'Month',];
  String _selectedFilter = 'All';
  final _complaintService = ComplaintsService.instance;
  List<ComplaintModel> get allComplaints => _allComplaints;
  List<ComplaintModel> get filteredComplaints => _filteredComplaints;
  List<String> get filters => _filters;
  String get selectedFilter => _selectedFilter;
  MaintenanceProvider(){
    _initComplaints();
  }

  Future<String?> deleteComplaintByID(String complaintID) async {
    try{
      debugPrint("onDelete occurred");
      _allComplaints.removeWhere((complaint) => complaint.id == complaintID);
      notifyListeners();
      await _complaintService.deleteComplaintByID(complaintID);
      return null;
    }catch(e){
      return e.toString();
    }
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

      _allComplaints = await _complaintService.getAllComplaints();
      _filteredComplaints.addAll(_allComplaints);
      notifyListeners();
    }catch(e){
      debugPrint("Error while fetching complaints: ${e.toString()}");
    }

    loadingComplaints = false;
    notifyListeners();

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
}
import 'package:flutter/material.dart';
import '../core/models/access_model.dart';
import '../core/models/access_request_model.dart';
import '../services/access_requests_service/access_request_service.dart';

class RequestAccessProvider extends ChangeNotifier {
  bool addingRequestAccess =  false;
  final List<AccessModel> _allAccessItems = [];
  List<AccessRequestModel> _allAccessRequests  = [];
  List<AccessRequestModel> _filteredAccessRequests  = [];

  final _requestsService = AccessRequestService.instance;
  final List<String> _filters = ['All', 'Week', 'Month',];
  String _selectedFilter = 'All';
  List<AccessRequestModel> get allAccessRequests => _allAccessRequests;
  List<AccessRequestModel> get filteredAccessRequests => _filteredAccessRequests;
  List<AccessModel> get allAccessItems => _allAccessItems;
  List<String> get filters => _filters;
  String get selectedFilter => _selectedFilter;
  RequestAccessProvider(){
    _initRequests();
  }

  void onAddRequestTap() async{

  }

  void _initRequests() async {
    try {
      _allAccessRequests = await _requestsService.getAllRequests();
      _filteredAccessRequests.addAll(_allAccessRequests);
      notifyListeners();
    } catch (e) {
      debugPrint('RequestAccessProvider: failed to fetch access items: $e');
    }
  }

  void onFilterUpdated(dynamic val){
    _selectedFilter = val;
    if(_selectedFilter == 'All'){
      _filteredAccessRequests = _allAccessRequests;
    }else if(_selectedFilter == 'Week'){
      _filteredAccessRequests = _getComplaintsOfCurrentWeek();
    }else{
      _filteredAccessRequests = _getComplaintsOfCurrentMonth();
    }
    notifyListeners();
  }

  List<AccessRequestModel> _getComplaintsOfCurrentWeek() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final start = end.subtract(const Duration(days: 7));

    return _allAccessRequests.where((complaint) {
      return complaint.createdAt.isAfter(start) &&
          complaint.createdAt.isBefore(end);
    }).toList();
  }

  List<AccessRequestModel> _getComplaintsOfCurrentMonth() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 1)
        : DateTime(now.year + 1, 1, 1);

    return _allAccessRequests.where((complaint) {
      return complaint.createdAt.isAfter(start) &&
          complaint.createdAt.isBefore(end);
    }).toList();
  }
}
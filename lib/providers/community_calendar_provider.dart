import 'package:flutter/cupertino.dart';
import '../core/models/community_event_model.dart';
import '../core/models/user_model.dart';
import '../services/community_service/community_service.dart';
import '../services/user_service/user_service.dart';

class CommunityCalendarProvider extends ChangeNotifier {
  bool loadingCommunityEvents = false;
  final _userService = UserService.instance;
  final _directoryService = CommunityService.instance;

  List<CommunityEventModel> _communityEvents = [];

  List<CommunityEventModel> get communityEvents => _communityEvents;


  CommunityCalendarProvider() {
    _initCommunityEvents();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      UserModel? user = await _userService.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  void _initCommunityEvents() async {
    try {
      loadingCommunityEvents = true;
      notifyListeners();

      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      _communityEvents = await _directoryService.initCommunityEvents(user.societyID ?? '1');
      loadingCommunityEvents = false;
      notifyListeners();
    } catch (e) {
      loadingCommunityEvents = false;
      notifyListeners();
      debugPrint('Error loading visitors: $e');
    }
  }
}
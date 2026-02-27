import 'package:flutter/cupertino.dart';
import '../core/models/community_event_model.dart';
import '../core/models/user_model.dart';
import '../services/user_service/user_service.dart';

class CommunityPollsProvider extends ChangeNotifier {
  bool loadingCommunityPolls = false;
  final _userService = UserService.instance;
  // final _communityService = CommunityService.instance;

  List<CommunityEventModel> _communityEvents = [];

  List<CommunityEventModel> get communityEvents => _communityEvents;


  CommunityPollsProvider() {
    _initCommunityPolls();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      UserModel? user = await _userService.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  void _initCommunityPolls() async {
 /*   try {
      loadingCommunityPolls = true;
      notifyListeners();

      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      _communityEvents = await _communityService.initCommunityEvents(user.societyID ?? '1');
      loadingCommunityPolls = false;
      notifyListeners();
    } catch (e) {
      loadingCommunityPolls = false;
      notifyListeners();
      debugPrint('Error loading visitors: $e');
    }    }
  */
  }
}
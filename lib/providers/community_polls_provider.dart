import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/community_poll_model.dart';
import '../core/models/user_model.dart';
import '../core/res/app_constants.dart';
import '../services/community_polls_service/community_polls_service.dart';
import '../services/user_service/user_service.dart';
import '../core/helpers/bottom_sheet_helper.dart';
import '../presentation/bottomsheets/create_poll_bottomsheet.dart';

class CommunityPollsProvider extends ChangeNotifier {
  bool loadingCommunityPolls = false;
  final _userService = UserService.instance;
  final _pollsService = CommunityPollsService.instance;

  List<CommunityPollModel> _communityPolls = [];

  List<CommunityPollModel> get communityPolls => _communityPolls;

  CommunityPollsProvider() {
    _initCommunityPolls();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  void _initCommunityPolls() async {
    try {
      loadingCommunityPolls = true;
      notifyListeners();
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }
      _communityPolls = await _pollsService.getPolls(user.societyID );
      loadingCommunityPolls = false;
      notifyListeners();
    } catch (e) {
      loadingCommunityPolls = false;
      notifyListeners();
      debugPrint('Error loading polls: $e');
    }
  }

  Future<void> onCreatePollTap(BuildContext context) async {
    final result = await BottomSheetHelper.showAdjustableModalBottomSheet<Map<String, dynamic>>(
      context: context,
      child: const CreatePollBottomSheet(),
    );
    if (result == null) return;
    final user = await getCurrentUser();
    if (user == null) return;
    final question = result['question'] as String? ?? '';
    final optionsList = result['options'] as List<dynamic>? ?? [];
    if (question.isEmpty || optionsList.length < 2) return;
    final hasImage = result['image'] != null && result['image'] is XFile;
    final options = optionsList.asMap().entries.map((e) => PollOption(id: '${e.key}', text: e.value.toString(), voteCount: 0)).toList();
    final now = DateTime.now().toUtc();
    final poll = CommunityPollModel(
      id: now.millisecondsSinceEpoch.toString(),
      question: question,
      createdBy: user.userName,
      createdAt: now,
      societyID: user.societyID,
      options: options,
      imageUrl: hasImage ? AppConstants.dummyImageUrl : null,
    );
    try {
      _communityPolls.insert(0, poll);
      notifyListeners();
      await _pollsService.createPoll(poll);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

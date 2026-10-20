import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/community_poll_model.dart';
import '../core/models/user_model.dart';
import '../services/community_polls_service/community_polls_service.dart';
import '../services/user_service/user_service.dart';
import '../core/helpers/bottom_sheet_helper.dart';
import '../presentation/bottomsheets/create_poll_bottomsheet.dart';

class CommunityPollsProvider extends ChangeNotifier {
  bool loadingCommunityPolls = false;
  final _userService = UserService.instance;
  final _pollsService = CommunityPollsService.instance;

  bool addingPoll = false;
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

  Future<void> refresh() async => _initCommunityPolls();

  Future<void> _initCommunityPolls() async {
    try {
      loadingCommunityPolls = true;
      notifyListeners();
      final user = await getCurrentUser();
      if (user == null) throw Exception('User not found');
      _communityPolls = await _pollsService.getPolls(user.societyID);
    } catch (e) {
      debugPrint('Error loading polls: $e');
    } finally {
      loadingCommunityPolls = false;
      notifyListeners();
    }
  }

  Future<bool?> onCreatePollTap(BuildContext context) async {
    final result = await BottomSheetHelper.showAdjustableModalBottomSheet<Map<String, dynamic>>(
      context: context,
      child: const CreatePollBottomSheet(),
      initialChildSize: 0.8
    );
    if (result == null) return null;
    final user = await getCurrentUser();
    if (user == null) return false;


    final question = result['question'] as String? ?? '';
    final optionsList = result['options'] as List<dynamic>? ?? [];
    if (question.isEmpty || optionsList.length < 2) return false;

    addingPoll = true;
    notifyListeners();


    try {
      final image = result['image'] is XFile ? result['image'] as XFile : null;
      final now = DateTime.now().toUtc();
      final pollId = now.millisecondsSinceEpoch.toString();
      String? imageUrl;
      if (image != null) {
        imageUrl = await _pollsService.uploadPollImage(image: image, pollId: pollId, societyID: user.societyID);
      }

      final options = optionsList
          .asMap()
          .entries
          .map((e) => PollOption(id: '${e.key}', text: e.value.toString(), voteCount: 0))
          .toList();

      final poll = CommunityPollModel(
        id: pollId,
        question: question,
        createdBy: user.userName,
        createdAt: now,
        societyID: user.societyID,
        options: options,
        imageUrl: imageUrl,
      );
      await _pollsService.createPoll(poll);
      _communityPolls.insert(0, poll);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      addingPoll = false;
      notifyListeners();
    }
  }

  Future<String?> deletePoll(CommunityPollModel poll) async {
    try {
      await _pollsService.deletePoll(pollId: poll.id);
      _communityPolls.removeWhere((p) => p.id == poll.id);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}

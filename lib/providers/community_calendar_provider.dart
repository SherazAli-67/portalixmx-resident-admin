import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/helpers/bottom_sheet_helper.dart';
import 'package:portalixmx_resident_admin/presentation/bottomsheets/create_calendar_event_bottomsheet.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/main_menu.dart';
import '../core/models/community_event_model.dart';
import '../core/models/user_model.dart';
import '../services/community_service/community_service.dart';
import '../services/user_service/user_service.dart';

class CommunityCalendarProvider extends ChangeNotifier {
  bool loadingCommunityEvents = false;
  final _userService = UserService.instance;
  final _communityService = CommunityService.instance;

  bool addingEvent = false;
  List<CommunityEventModel> _communityEvents = [];

  List<CommunityEventModel> get communityEvents => _communityEvents;

  CommunityCalendarProvider() {
    _initCommunityEvents();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async => _initCommunityEvents();

  Future<void> _initCommunityEvents() async {
    try {
      loadingCommunityEvents = true;
      notifyListeners();

      final user = await getCurrentUser();
      if (user == null) throw Exception('User not found');

      _communityEvents = await _communityService.initCommunityEvents(user.societyID);
      _communityEvents.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    } catch (e) {
      debugPrint('Error loading events: $e');
    } finally {
      loadingCommunityEvents = false;
      notifyListeners();
    }
  }

  Future<CommunityEventModel?> onCreateEventTap({CommunityEventModel? existing}) async {
    final result = await BottomSheetHelper.showDraggableBottomSheet(
      scaffoldKey: scaffoldKey,
      child: const CreateCalendarEventBottomSheet(),
      initialHeight: 0.8
    );
    if (result == null) return null;

    final user = await UserService.instance.getCurrentUser();
    if (user == null) throw Exception("User not found");

    addingEvent = true;
    notifyListeners();

    try {
      final title = result['eventTitle'] as String? ?? '';
      final description = result['eventDescription'] as String? ?? '';
      final image = result['image'] as XFile?;
      final eventDate = result['eventDate'] as DateTime?;
      final eventTime = result['eventTime'] as TimeOfDay?;
      if (title.isEmpty || eventDate == null || eventTime == null) return null;

      final now = DateTime.now().toUtc();
      final eventId = existing?.id ?? now.toIso8601String();
      var imageUrl = existing?.imageUrl ?? '';
      if (image != null) {
        imageUrl = await _communityService.uploadEventImage(image: image, eventId: eventId);
      }

      final event = CommunityEventModel(
        id: eventId,
        eventTitle: title,
        eventDescription: description,
        eventDate: eventDate,
        eventTime: eventTime,
        createdAt: existing?.createdAt ?? now,
        societyID: user.societyID,
        imageUrl: imageUrl,
      );

      await _communityService.addUpdateEvent(event: event);
      final index = _communityEvents.indexWhere((e) => e.id == eventId);
      if (index >= 0) {
        _communityEvents[index] = event;
      } else {
        _communityEvents.add(event);
      }

      _communityEvents.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      notifyListeners();
      addingEvent = false;
      return event;
    } catch (e) {
      addingEvent = false;
      notifyListeners();
      return null;
    }

  }

  Future<String?> deleteEvent({required CommunityEventModel event}) async {
    try {
      await _communityService.deleteEvent(eventId: event.id);
      _communityEvents.removeWhere((e) => e.id == event.id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

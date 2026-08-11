import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

      _communityEvents = await _communityService.initCommunityEvents(user.societyID );
      loadingCommunityEvents = false;
      notifyListeners();
    } catch (e) {
      loadingCommunityEvents = false;
      notifyListeners();
      debugPrint('Error loading visitors: $e');
    }
  }

  void onCreateEventTap()async {
   final result = await BottomSheetHelper.showDraggableBottomSheet(scaffoldKey: scaffoldKey, child: CreateCalendarEventBottomSheet());
   if(result != null){
     UserModel? user = await UserService.instance.getCurrentUser();
     if(user == null) throw Exception("User not found");

     String title = result['eventTitle'];
     String description = result['eventDescription'];
     // XFile image = result['image'];
     DateTime eventDate = result['eventDate'];
     TimeOfDay eventTime = result['eventTime'];

     DateTime now = DateTime.now().toUtc();
     CommunityEventModel event = CommunityEventModel(id: now.toIso8601String(),
         eventTitle: title,
         eventDescription: description,
         eventDate: eventDate,
         eventTime: eventTime,
         createdAt: now,
         societyID: user.societyID,
         imageUrl: 'https://images.unsplash.com/photo-1561314945-0562f5b6d2c6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8RWlkfGVufDB8fDB8fHww');
     try{
       _communityEvents.add(event);
       notifyListeners();

       await _communityService.addUpdateEvent(event: event);
     }catch(e){
       debugPrint(e.toString());
     }
  }
  }
}
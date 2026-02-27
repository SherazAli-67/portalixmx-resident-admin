import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../services/user_service/user_service.dart';

class HomeProvider extends ChangeNotifier {

  final _userService = UserService.instance;
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  bool loading = false;

  Future<UserModel?> getCurrentUser() async {
    try {
      UserModel? user = await _userService.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  void onTabChange(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/user_model.dart';
import '../services/profile_service/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _profileService = ProfileService.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  bool _loadingProfile = false;
  bool _updatingProfile = false;

  UserModel? _user;
  XFile? _pickedImage;
  bool get loadingProfile => _loadingProfile;
  bool get updatingProfile => _updatingProfile;
  UserModel? get user => _user;
  XFile? get pickedImage => _pickedImage;

  ProfileProvider() {
    _loadingProfile = true;
    _authSub = _auth.authStateChanges().listen((user) {
      _loadUser(user);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> reloadCurrentUser() async {
    await _loadUser(_auth.currentUser);
  }

  Future<void> _loadUser(User? user) async {
    _loadingProfile = true;
    notifyListeners();
    try {
      if (user == null) {
        _user = null;
      } else {
        _user = await _fetchCurrentUserWithRetry();
      }
    } catch (e) {
      debugPrint("Error while fetching user: ${e.toString()}");
      _user = null;
    }
    _loadingProfile = false;
    notifyListeners();
  }

  Future<UserModel?> _fetchCurrentUserWithRetry() async {
    Object? lastError;
    for (var i = 0; i < 3; i++) {
      try {
        return await _profileService.getCurrentUser();
      } catch (e) {
        lastError = e;
        if (i < 2) {
          await Future<void>.delayed(Duration(milliseconds: 400 * (i + 1)));
        }
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    return null;
  }

  void onPickImageTap() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      _pickedImage = selectedImage;
      notifyListeners();
    }
  }

  Future<String?> onUpdateTap({
    required String name,
    required String phoneNum,
  }) async {
    String? errorMessage;
    if (user != null) {
      _updatingProfile = true;
      notifyListeners();
      try {
        final updatedUser = user!.copyWith(
          userName: name,
          phoneNum: phoneNum.isNotEmpty ? phoneNum : null,
        );
        _user = updatedUser;
        notifyListeners();
        await _profileService.updateUser(user: updatedUser);
      } catch (e) {
        errorMessage = e.toString();
      }
    } else {
      errorMessage = 'User not found';
    }

    _updatingProfile = false;
    notifyListeners();
    return errorMessage;
  }
}

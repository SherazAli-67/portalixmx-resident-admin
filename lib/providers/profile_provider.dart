import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/user_model.dart';
import '../services/auth_service/auth_service.dart';
import '../services/profile_service/profile_service.dart';
import '../services/push_notification_service/push_notification_service.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class ProfileProvider extends ChangeNotifier {
  final _profileService = ProfileService.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  bool _loadingProfile = false;
  bool _updatingProfile = false;
  bool _recoveringFromFailedLoad = false;
  int _loadGeneration = 0;
  final GoRouterRefreshNotifier routerRefresh = GoRouterRefreshNotifier();

  UserModel? _user;
  XFile? _pickedImage;
  String? _profileLoadError;
  bool get loadingProfile => _loadingProfile;
  bool get updatingProfile => _updatingProfile;
  UserModel? get user => _user;
  XFile? get pickedImage => _pickedImage;
  String? get profileLoadError => _profileLoadError;

  ProfileProvider() {
    _loadingProfile = true;
    _authSub = _auth.authStateChanges().listen((user) {
      _loadUser(user);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    routerRefresh.dispose();
    super.dispose();
  }

  void clearProfileLoadError() {
    if (_profileLoadError == null) return;
    _profileLoadError = null;
    notifyListeners();
  }

  Future<void> recoverFromFailedProfileLoad() async {
    if (_recoveringFromFailedLoad) return;
    _recoveringFromFailedLoad = true;
    _profileLoadError = 'unableToLoadProfile';
    notifyListeners();
    try {
      await PushNotificationService.instance.removeTokenForSignOut();
      await AuthService.instance.signOut();
    } finally {
      _recoveringFromFailedLoad = false;
    }
  }

  Future<void> reloadCurrentUser() async {
    await _loadUser(_auth.currentUser);
  }

  Future<void> _loadUser(User? user) async {
    final generation = ++_loadGeneration;
    _loadingProfile = true;
    if (user != null) {
      _profileLoadError = null;
    }
    notifyListeners();
    routerRefresh.refresh();
    try {
      if (user == null) {
        if (generation != _loadGeneration) return;
        _user = null;
      } else {
        final fetched = await _fetchCurrentUserWithRetry();
        debugPrint("Fetched: ${fetched?.userID}");
        if (generation != _loadGeneration) return;
        _user = fetched;
        if (_user != null) {
          await PushNotificationService.instance.syncTokenForCurrentUser();
          if (generation != _loadGeneration) return;
        } else {
          _profileLoadError = 'unableToLoadProfile';
        }
      }
    } catch (e) {
      if (generation != _loadGeneration) return;
      debugPrint("Error while fetching user: ${e.toString()}");
      _user = null;
      if (user != null) {
        _profileLoadError = 'unableToLoadProfile';
      }
    }
    if (generation != _loadGeneration) return;
    _loadingProfile = false;
    notifyListeners();
    routerRefresh.refresh();
  }

  Future<UserModel?> _fetchCurrentUserWithRetry() async {
    Object? lastError;
    for (var i = 0; i < 3; i++) {
      try {
        final user = await _profileService.getCurrentUser();
        if (user != null) {
          return user;
        }
      } catch (e) {
        lastError = e;
      }
      if (i < 2) {
        await Future<void>.delayed(Duration(milliseconds: 400 * (i + 1)));
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    return null;
  }

  void onPickImageTap() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
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
        String? imageUrl = user?.profileImg;
        if(_pickedImage != null){
          imageUrl = await _profileService.uploadImage(selectedImageFile: _pickedImage!, userID: user!.userID);
        }
        final updatedUser = user!.copyWith(
          userName: name,
          profileImg: imageUrl,
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

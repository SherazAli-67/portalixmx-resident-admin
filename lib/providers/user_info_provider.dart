import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoProvider extends ChangeNotifier {
  final String _isResidentAdminKey = 'isResidentAdmin';
  final String _tokenKey = 'token';
  final String _userIDKey = 'userID';
  final String _userNameKey = 'userName';
  final String _userEmailKey = 'emailAddress';
  final String _tokenExpiryKey = 'tokenExpiry';

  bool _isResidentAdmin = false;
  String? _token;
  String? _userID;
  String? _userName;
  String? _emailAddress;
  bool _isLoggedIn = false;
  DateTime? _tokenExpiry;

  bool get isResidentAdmin => _isResidentAdmin;
  String? get token => _token;
  String? get userID => _userID;
  String? get userName => _userName;
  String? get emailAddress => _emailAddress;
  bool get isLoggedIn => _isLoggedIn;
  DateTime? get tokenExpiry => _tokenExpiry;

  bool get isTokenExpired {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  UserInfoProvider(){
    _initUserInfo();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_userNameKey, name);
  }

  Future<void> setUserInfo({
    required String token, 
    required String name, 
    required String userID, 
    required String email, 
    required bool isResidentAdmin,
    required DateTime expiry
  }) async {
    _token = token;
    _userName = name;
    _userID = userID;
    _emailAddress = email;
    _isResidentAdmin = isResidentAdmin;
    _tokenExpiry = expiry;
    notifyListeners();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_tokenKey, token);
    await sharedPreferences.setString(_userIDKey, userID);
    await sharedPreferences.setString(_userNameKey, name);
    await sharedPreferences.setString(_userEmailKey, email);
    await sharedPreferences.setBool(_isResidentAdminKey, isResidentAdmin);
    await sharedPreferences.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  void setLogin(bool isLogin){
    _isLoggedIn = isLogin;
    notifyListeners();
  }
  
  void _initUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _token = sharedPreferences.getString(_tokenKey);
    _userID = sharedPreferences.getString(_userIDKey);
    _emailAddress = sharedPreferences.getString(_userEmailKey);
    _userName = sharedPreferences.getString(_userNameKey);
    _isResidentAdmin = sharedPreferences.getBool(_isResidentAdminKey) ?? false;
    
    final expiryString = sharedPreferences.getString(_tokenExpiryKey);
    if (expiryString != null) {
      _tokenExpiry = DateTime.tryParse(expiryString);
    }
    
    // Check if token is expired on app start
    if (_token != null && isTokenExpired) {
      await reset();
    } else if (_token != null) {
      _isLoggedIn = true;
    }
    
    notifyListeners();
  }

  Future<void> reset() async {
    _token = null;
    _userID = null;
    _emailAddress = null;
    _userName = null;
    _isResidentAdmin = false;
    _isLoggedIn = false;
    _tokenExpiry = null;
    notifyListeners();
    
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }


}
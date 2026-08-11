import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/res/firebase_constant.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  GoRouter? _router;
  String? _currentToken;

  Future<void> initialize({required GoRouter router}) async {
    _router = router;
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((_) {});
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    await _handleInitialMessage();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _syncToken(user.uid);
    }
  }

  Future<void> removeTokenForSignOut() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final token = _currentToken ?? await FirebaseMessaging.instance.getToken(vapidKey: 'BD2xgrw8u7kwU3Gg6QVW8R7cJQiBGO0NMzOqEYSocRYuOKI9SJSvIc-u1fgDRueMx9x42jNOQZdTN8__RO_LE3I');
      if (uid == null || token == null) return;
      await FirebaseFirestore.instance
          .collection(FirebaseConst.residentAdminCol)
          .doc(uid)
          .update({'token' : token});
    } catch (_) {}
    _currentToken = null;
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromMessage(message);
      });
    }
  }

  void _handleOpenedMessage(RemoteMessage message) {
    _navigateFromMessage(message);
  }

  void _navigateFromMessage(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route == null || route.isEmpty || _router == null) return;
    _router!.go(route);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) return;
    await _syncToken(user.uid);
  }

  Future<void> _onTokenRefresh(String token) async {
    _currentToken = token;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection(FirebaseConst.residentAdminCol)
        .doc(uid)
        .set({'token' : token},
      SetOptions(merge: true),
    );
  }

  Future<void> _syncToken(String uid) async {
    try{
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint("Token: $token");
      if (token == null) return;
      _currentToken = token;
      await FirebaseFirestore.instance
          .collection(FirebaseConst.residentAdminCol)
          .doc(uid)
          .set(
        {'token' : token},
        SetOptions(merge: true),
      );
    }catch(e){
      debugPrint("Exception: ${e.toString()}");
    }

  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../core/res/firebase_constant.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  GoRouter? _router;
  // String? _currentToken;

  Future<void> initialize({required GoRouter router}) async {
    _router = router;
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
    await _handleInitialMessage();
  }

  Future<void> syncTokenForCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _syncToken(uid);
  }

  Future<void> removeTokenForSignOut() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection(FirebaseConst.residentAdminCol)
          .doc(uid)
          .update({'token': FieldValue.delete()});
    } catch (_) {}
    // _currentToken = null;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] as String?;
    final body = message.notification?.body ?? message.data['body'] as String?;
    final text = [title, body].whereType<String>().where((s) => s.isNotEmpty).join('\n');
    if (text.isEmpty) return;
    Fluttertoast.showToast(msg: text, toastLength: Toast.LENGTH_LONG);
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

  Future<void> _onTokenRefresh(String token) async {
    try {
      // _currentToken = token;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _writeToken(uid, token);
    } catch (e) {
      debugPrint("Exception syncing FCM token: ${e.toString()}");
    }
  }

  Future<void> _syncToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      // _currentToken = token;
      await _writeToken(uid, token);
    } catch (e) {
      debugPrint("Exception syncing FCM token: ${e.toString()}");
    }
  }

  Future<void> _writeToken(String uid, String token) async {
    final ref = FirebaseFirestore.instance
        .collection(FirebaseConst.residentAdminCol)
        .doc(uid);
    final snap = await ref.get();
    if (!snap.exists) return;
    await ref.update({'token': token});
  }
}

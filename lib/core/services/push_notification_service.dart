import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/services/firestore_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background FCM message: ${message.messageId}');
}

class PushNotificationService {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _started = false;

  PushNotificationService({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  Future<void> init() async {
    if (_started) return;
    _started = true;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground FCM message: ${message.messageId}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Opened from FCM message: ${message.messageId}');
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial FCM message: ${initialMessage.messageId}');
    }

    _authSub = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _registerTokenForUser(user.uid);
      }
    });

    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) async {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _firestoreService.registerPushToken(uid, token);
      }
    });
  }

  Future<void> _registerTokenForUser(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firestoreService.registerPushToken(userId, token);
    }
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }
}

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _tokenUpdates = StreamController<String>.broadcast();
  StreamSubscription<String>? _tokenRefreshSub;
  bool _initialized = false;

  /// Emits whenever a non-empty FCM token is obtained or refreshed.
  Stream<String> get tokenUpdates => _tokenUpdates.stream;

  bool _canReceivePush(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<String?> _waitForApnsToken() async {
    if (!Platform.isIOS) return null;

    var apnsToken = await _firebaseMessaging.getAPNSToken();
    if (apnsToken != null) return apnsToken;

    for (var attempt = 1; attempt <= 20; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) return apnsToken;
    }

    debugPrint('APNS token unavailable after waiting');
    return null;
  }

  Future<String?> _readFcmToken() async {
    for (var attempt = 1; attempt <= 5; attempt++) {
      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null && token.isNotEmpty) return token;
      } on FirebaseException catch (e) {
        debugPrint('FCM getToken attempt $attempt failed: ${e.code}');
      } catch (e) {
        debugPrint('FCM getToken attempt $attempt failed');
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  void _storeToken(String token) {
    if (token.isEmpty || token == fcmToken) return;
    fcmToken = token;
    _tokenUpdates.add(token);
  }

  Future<String?> setupAPNS() async {
    if (!Platform.isIOS) return null;

    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (!_canReceivePush(settings.authorizationStatus)) {
        debugPrint('Notification permission not granted');
        return null;
      }

      return _waitForApnsToken();
    } catch (e) {
      debugPrint('APNS setup failed');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await setupAPNS();
        if (apnsToken == null) {
          debugPrint('Cannot get FCM token because APNS is unavailable');
          return null;
        }
      }

      final token = await _readFcmToken();
      if (token == null) {
        debugPrint('Firebase returned an empty FCM token');
        return null;
      }

      _storeToken(token);
      return token;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting FCM token: ${e.code}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error getting FCM token');
      return null;
    }
  }

  Future<void> init() async {
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    region = currentTimeZone.identifier;

    if (!_initialized) {
      initializeTimeZones();
      setLocalLocation(getLocation(currentTimeZone.identifier));

      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _tokenRefreshSub ??= _firebaseMessaging.onTokenRefresh.listen((token) {
        if (token.isEmpty) return;
        _storeToken(token);
      });

      _initialized = true;

      if (!_canReceivePush(settings.authorizationStatus)) {
        return;
      }
    }

    await getToken();
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}

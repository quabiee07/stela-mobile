import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class NotificationService {
  late final FirebaseMessaging _firebaseMessaging;
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> setupAPNS() async {
    String? apnsToken = await _firebaseMessaging.getAPNSToken();
    int attempts = 0;
    while (apnsToken == null && attempts < 10) {
      // 5 → 10
      await Future.delayed(const Duration(seconds: 2)); // 1s → 2s
      apnsToken = await _firebaseMessaging.getAPNSToken();
      attempts++;
      debugPrint(
        "APNS attempt $attempts: ${apnsToken != null ? '✅ resolved' : '⏳ null'}",
      );
    }
    if (apnsToken == null) {
      debugPrint("⚠️ APNS token still null after $attempts attempts");
    }
  }

  Future<String?> getToken() async {
    try {
      if (!Platform.isAndroid) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        if (!iosInfo.isPhysicalDevice) {
          fcmToken = "simulator_dummy_token";
          return fcmToken;
        }
        await setupAPNS();

        // Don't proceed if APNS never resolved
        if (await _firebaseMessaging.getAPNSToken() == null) {
          debugPrint("❌ Aborting getToken — APNS unavailable");
          return null;
        }
      }
      fcmToken = await _firebaseMessaging.getToken();
      return fcmToken;
    } on IOException catch (e) {
      debugPrint(
        "Error getting FCM token: $e. Device info: ${await DeviceInfoPlugin().deviceInfo}",
      );
      return null;
    } catch (e) {
      debugPrint("Unexpected error getting FCM token: $e");
      return null;
    }
  }

  // Future<String?> getToken() async {
  //   try {
  //     if (!Platform.isAndroid) {
  //       final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //       final iosInfo = await deviceInfo.iosInfo;
  //       if (!iosInfo.isPhysicalDevice) {
  //         fcmToken = "simulator_dummy_token";
  //         return fcmToken;
  //       }
  //       await setupAPNS();
  //     }
  //     fcmToken = await _firebaseMessaging.getToken();
  //     return fcmToken;
  //   } on IOException catch (e) {
  //     debugPrint(
  //       "Error getting FCM token: $e. Device info: ${await DeviceInfoPlugin().deviceInfo}",
  //     );
  //     return null;
  //   } catch (e) {
  //     debugPrint("Unexpected error getting FCM token: $e");
  //     return null;
  //   }
  // }

  Future<void> init() async {
    TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
    _firebaseMessaging = FirebaseMessaging.instance;

    initializeTimeZones();
    region = currentTimeZone.identifier;
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
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await getToken();
    }
  }
}

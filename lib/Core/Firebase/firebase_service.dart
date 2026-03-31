// firebase_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

class FirebaseService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'flutter_notification',
    'flutter_notification_title',
    description: 'Default notifications channel',
    importance: Importance.high,
    enableLights: true,
    showBadge: true,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initializeFirebase({
    FutureOr<void> Function(Map<String, dynamic> data)? onNotificationTap,
  }) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.log.i('Notification tapped. payload: ${response.payload}');

        final payload = response.payload;
        if (payload == null || payload.trim().isEmpty) return;

        Map<String, dynamic>? data;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            data = decoded.map((k, v) => MapEntry(k.toString(), v));
          }
        } catch (_) {
          // Older builds stored payload using `message.data.toString()` (not JSON).
          // Ignore safely rather than crashing.
        }

        if (data != null && onNotificationTap != null) {
          Future(() => onNotificationTap(data!));
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _requestNotificationPermission();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      AppLogger.log.i(
        'Notification permission: ${settings.authorizationStatus}',
      );
    } catch (e, st) {
      AppLogger.log.w('requestPermission failed: $e\n$st');
    }
  }

  Future<String?> _getTokenWithBackoff() async {
    const delays = [1, 2, 4, 8];
    for (final seconds in delays) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        AppLogger.log.w('getToken failed (retry in ${seconds}s): $e');
      }
      await Future.delayed(Duration(seconds: seconds));
    }

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      AppLogger.log.e('getToken final failure: $e\n$st');
      return null;
    }
  }

  Future<void> fetchFCMTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString('fcmToken');

    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      AppLogger.log.i('Existing FCM Token: $_fcmToken');
      return;
    }

    final token = await _getTokenWithBackoff();
    _fcmToken = token;

    if (token != null && token.isNotEmpty) {
      await prefs.setString('fcmToken', token);
      AppLogger.log.i('FCM Token: $token');
    } else {
      AppLogger.log.w(
        'No FCM token (device/config/network). Will retry later.',
      );
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'flutter_notification',
      'flutter_notification_title',
      channelDescription: 'Default notifications channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const details = NotificationDetails(android: androidDetails);

    final nid = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      id: nid,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      notificationDetails: details,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  void listenToMessages({
    required void Function(RemoteMessage) onMessage,
    required void Function(RemoteMessage) onMessageOpenedApp,
  }) {
    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  Future<RemoteMessage?> getInitialMessage() {
    return FirebaseMessaging.instance.getInitialMessage();
  }
}


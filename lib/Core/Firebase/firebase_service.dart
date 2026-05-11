// firebase_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Firebase/fcm_token_helper.dart';

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

  StreamSubscription<String>? _tokenRefreshSub;

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

    _startTokenRefreshListener();
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

  void _startTokenRefreshListener() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) async {
        final t = token.trim();
        if (t.isEmpty) return;

        _fcmToken = t;
        await FcmTokenHelper.cacheToken(t);
        AppLogger.log.i('FCM token refreshed: ${FcmTokenHelper.redact(t)}');
      },
      onError: (e) {
        AppLogger.log.w('FCM onTokenRefresh error: $e');
      },
    );
  }

  /// Fetches FCM token and caches it (and updates cache if token rotated).
  Future<void> fetchFCMTokenIfNeeded({bool forceRefresh = false}) async {
    // Keep local value in sync with prefs + Firebase.
    _fcmToken = await FcmTokenHelper.ensureCachedToken(
      forceRefresh: forceRefresh,
    );

    if (_fcmToken == null || _fcmToken!.trim().isEmpty) {
      AppLogger.log.w('No FCM token available yet. Will retry later.');
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
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


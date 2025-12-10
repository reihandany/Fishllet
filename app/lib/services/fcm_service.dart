import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FCM SERVICE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Service untuk handle Firebase Cloud Messaging (FCM):
/// - Dapatkan FCM token
/// - Handle foreground notifications (dengan local notifications)
/// - Handle background notifications
class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM dan request permission
  static Future<void> initializeFCM() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permission (iOS & Android 13+)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ Provisional notification permission granted');
      } else {
        debugPrint('❌ Notification permission denied');
      }

      // Get FCM token
      await getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  /// Dapatkan FCM token
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint('✅ FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup message handlers (foreground & background)
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message received:');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // Show local notification di foreground
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Handle background message (dipanggil saat app di background/terminated)
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped:');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      // Handle navigation based on message data
    });
  }

  /// Background message handler (harus top-level function)
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    debugPrint('📬 Background message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }

  /// Listen to FCM token refresh
  static void listenTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      // Kirim token baru ke backend untuk update database
    });
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(initSettings);
    debugPrint('✅ Local notifications initialized');
  }

  /// Show local notification (untuk foreground)
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fcm_channel_id',
      'FCM Notifications',
      channelDescription: 'Notifikasi dari FCM',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    debugPrint('✅ Local notification shown: $title');
  }
}

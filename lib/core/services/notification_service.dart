import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised before this is called.
  // No need to show a local notification here — Android shows it automatically
  // from the notification payload when the app is in the background/terminated.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'payment_requests';
  static const _channelName = 'Payment Requests';
  static const _channelDescription =
      'Notifications for incoming payment requests';

  /// Call once in main() after Firebase.initializeApp().
  Future<void> initialize() async {
    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permission (Android 13+ / iOS)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 3. Set up local notifications plugin (for foreground display)
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidInitSettings);
    await _localNotifications.initialize(initSettings);

    // 4. Create the Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);

    // 5. Handle notifications received while app is in the FOREGROUND
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  /// Displays a local notification banner when the app is open.
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Returns the current FCM device token (null if not available).
  Future<String?> getToken() => _fcm.getToken();

  /// Stream that emits a new token whenever it is refreshed.
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  // Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'bengkelsampah_channel',
    'Bengkel Sampah Notifications',
    description: 'This channel is used for Bengkel Sampah notifications.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _sendTokenToServer(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _sendTokenToServer(newToken);
      });

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');

      // Show local notification
      await _showLocalNotification(message);
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    debugPrint('Notification tapped: ${message.data}');

    // Handle navigation based on notification data
    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'];
      // Navigate to specific screen based on notification data
      // This will be handled by the navigation service
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bengkelsampah_channel',
      'Bengkel Sampah Notifications',
      channelDescription:
          'This channel is used for Bengkel Sampah notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        // Send token to server
        await _apiService.updateFCMToken(token);
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');

  // Initialize Firebase if not already done
  await Firebase.initializeApp();

  // Initialize local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'bengkelsampah_channel',
    'Bengkel Sampah Notifications',
    description: 'This channel is used for Bengkel Sampah notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Show notification
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'bengkelsampah_channel',
    'Bengkel Sampah Notifications',
    channelDescription:
        'This channel is used for Bengkel Sampah notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: message.data.toString(),
  );
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:try1/app_db.dart';
import 'package:try1/firebase_options.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => instance;

  static final PushNotificationsManager instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "custom_channel_1", // Channel ID
    'Customer Update', // Channel name
    description: 'channel_description',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
  );

  void deleteNotification(String channelId) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      appDb.fcmToken = token;
      print("Push Messaging token: $token");
    }

    // Listen for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null && message.notification?.android != null) {
        _showNotificationWithDefaultSound(message);
      }
    });

    // Handle messages when the app is opened from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Initial message: ${initialMessage.data}");
    }

    // Handle messages when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app: ${message.data}");
    });

    var android = const AndroidInitializationSettings('mipmap/ic_launcher');
    var platform = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(
      platform,
      onDidReceiveNotificationResponse: (details) {
        print("Notification selected: ${details.payload}");
        if (details.payload != null) {
          print('Payload: ${jsonDecode(details.payload!)}');
        }
      },
    );
  }

  Future<void> _showNotificationWithDefaultSound(RemoteMessage payload) async {
    var data = payload.data;

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'customer_channel_1',
      'Customer Update',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );
    var notification = payload.notification;
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    print(
        "${payload.notification!.title}  ${payload.data} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print("$notification -------------------");

    print(
        "====================_showNotificationWithDefaultSound=======================");
    await flutterLocalNotificationsPlugin.show(
      0,
      payload.notification!.title,
      payload.notification!.body,
      platformChannelSpecifics,
      payload: jsonEncode(data),
    );
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("BackGround Message Handler");
  //await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

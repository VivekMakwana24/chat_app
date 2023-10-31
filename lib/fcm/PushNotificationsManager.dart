import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gotms_chat/core/db/app_db.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'customer_channel',
    'Customer Update',
    importance: Importance.high,
  );

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // final bool? granted = await androidImplementation?.requestPermission();
    }
  }
  Future<void> init() async {
    // _requestPermissions();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getToken().then((String? token) {
      appDB.fcmToken = token!;
      debugPrint("Push Messaging token: ${appDB.fcmToken}");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _showNotificationWithDefaultSound(message);
      }
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint("====================initialMessage=======================");
      debugPrintRemoteMessage(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("====================onMessageOpenedApp=======================");
      debugPrintRemoteMessage(message);
      updateNavigation(message.data);
    });

    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = DarwinInitializationSettings();
    var platform = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(
      platform,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        debugPrint("====================onDidReceiveNotificationResponse=======================");
        debugPrint(notificationResponse.payload);
        updateNavigation(jsonDecode(notificationResponse.payload!));
        return Future.value(jsonDecode(notificationResponse.payload!));
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future _showNotificationWithDefaultSound(RemoteMessage payload) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    var notification = payload.notification;
    debugPrint("====================_showNotificationWithDefaultSound=======================");
    debugPrintRemoteMessage(payload);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch,
      notification?.title ?? "",
      notification?.body ?? "",
      notificationDetails,
      payload: jsonEncode(payload.data),
    );
  }

//Data: {"clickaction":"FLUTTERNOTIFICATIONCLICK","poll_id":"2","tag":"poll_push","body":"Hurry up new poll added","title":"Poll","message":"Hurry up new poll added"}

}

const String pollPush = "poll_push";
const String storyPush = "story_push";
const String quizPush = "quiz_push";

void updateNavigation(Map data) {
  debugPrint("===============updateNavigation=================");
  debugPrint(jsonEncode(data));

  switch (data["tag"]) {
    case pollPush:
      {
        // navigator.pushOrReplacementNamed(RouteName.landing, arguments: Map.of({"tab": 2}));
        break;
      }

    case quizPush:
    case storyPush:
      {
        debugPrint("StoryPUSH NAVIGATE:");
        // navigator.pushOrReplacementNamed(RouteName.landing, arguments: Map.of({"tab": 0}));
        break;
      }
  }
}

debugPrintRemoteMessage(RemoteMessage message) {
  debugPrint("Notification_TITLE: ${jsonEncode(message.notification?.title)}");
  debugPrint("Notification_BODY: ${jsonEncode(message.notification?.body)}");
  debugPrint("Data: ${jsonEncode(message.data)}");
}

/*
It must not be an anonymous function.
It must be a top-level function (e.g. not a class method which requires initialization).
*/
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');

  updateNavigation(message.data);
}

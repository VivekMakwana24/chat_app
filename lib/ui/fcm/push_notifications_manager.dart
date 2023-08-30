import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> init() async {
    await firebaseMessaging.setAutoInitEnabled(true);

    await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

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

    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings ios = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var platform = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(
      platform,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint("====================onSelectNotification=======================");
        if (details.payload != null) {
          debugPrint(details.payload!);
          updateNavigation(jsonDecode(details.payload!));
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    firebaseMessaging.getToken().then((String? token) async {
      appDB.fcmToken = token ?? '';
      // appDB.fcmToken = token!;
      debugPrint("Push Messaging token: ${token}");
      debugPrint("Push Messaging fcmtoken: ${appDB.fcmToken}");
      debugPrint("AppDB${appDB.currentUserId}");

      if (appDB.currentUserId.isNotEmpty) {
        Future.delayed(
          const Duration(seconds: 5),
          () {
            firebaseChatManager.updateDeviceToken(appDB.currentUserId);
          },
        );
      }
    });

    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint("NotificationData${message.data}");
        RemoteNotification? notification = message.notification;

        if (Platform.isAndroid) {
          _showNotificationWithDefaultSound(message, message.data['title'] ?? '', message.data['message'] ?? '');
        }
      });
    } catch (e) {
      // Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.BOTTOM);
    }

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint("====================initialMessage=======================");
      printRemoteMessage(initialMessage);
      updateNavigation(initialMessage.data);
    }

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.notificationResponse != null &&
        notificationAppLaunchDetails.notificationResponse!.payload != null) {
      debugPrint("notificationAppLaunchDetails");
      Map data = jsonDecode(notificationAppLaunchDetails.notificationResponse!.payload!);
      updateNavigation(data);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("====================onMessageOpenedApp=======================");
      printRemoteMessage(message);
      updateNavigation(message.data);
    });
  }

  Future _showNotificationWithDefaultSound(RemoteMessage payload, String title, String body) async {
    if (payload.data['tag'] == newJob) {
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
          'custom_sound', 'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('knock_knock'),
          playSound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } else {
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    var androidNotificationDetails = AndroidNotificationDetails(
      payload.data['tag'] == newJob ? 'custom_sound' : 'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: payload.data['tag'] == newJob ? const RawResourceAndroidNotificationSound('knock_knock') : null,
      styleInformation: const BigTextStyleInformation(''),
      enableVibration: true,
      icon: 'mipmap/ic_launcher',
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      sound: 'Resources/knock_knock.wav',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    var notification = payload.notification;
    debugPrint("====================_showNotificationWithDefaultSound=======================");
    debugPrint("Payload${jsonEncode(payload.data)}");
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      title != "" ? title : notification?.title,
      body != "" ? body : notification?.body,
      notificationDetails,
      payload: jsonEncode(payload.data),
    );
  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    debugPrint("payload$payload");
    debugPrint("TITLE$title");
    // display a dialog with the notification details, tap ok to go to another page
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint("====================onSelectNotification=======================");
  updateNavigation(jsonDecode(notificationResponse.payload!));
  // ignore: avoid_print
  debugPrint('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    debugPrint('notification action tapped with input: ${notificationResponse.input}');
    updateNavigation(jsonDecode(notificationResponse.payload ?? '{}'));
  }
}

void updateNavigation(Map data) async {
  debugPrint("===============updateNavigation=================");
  debugPrint(jsonEncode(data));
  debugPrint("notificationData $data");
  switch (data['tag']) {
    case newChatMessage:
      _navigateToChatDetails(data);
      break;
  }
}

void _navigateToChatDetails(Map data) {}

printRemoteMessage(RemoteMessage message) {
  debugPrint("Notification_TITLE: ${jsonEncode(message.notification?.title)}");
  debugPrint("Notification_BODY: ${jsonEncode(message.notification?.body)}");
  debugPrint("Data: ${(message)}");
}

/*
It must not be an anonymous function.
It must be a top-level function (e.g. not a class method which requires initialization).
*/

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("firebaseMessagingBackgroundHandler");
  await Firebase.initializeApp();
  // updateNavigation(message.data);
}

const String newChatMessage = "new_chat_message";
const String newJob = "new_job";

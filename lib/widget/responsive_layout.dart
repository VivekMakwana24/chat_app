import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/controller/notification_controller.dart';
import 'package:flutter_demo_structure/ui/web/widgets/notification_icon.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget tabletScreenLayout;
  final Widget mobileScreenLayout;

  ResponsiveLayout({
    super.key,
    required this.webScreenLayout,
    required this.tabletScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final _controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    getPermission();

    loginAndNavigateToHome();

    messageListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return widget.webScreenLayout;
        } else if (constraints.maxWidth <= 200) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: NotificationIcon(),
          );
        } else if (constraints.maxWidth < 580) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: NotificationIcon(),
          );
        } else {
          return widget.webScreenLayout;
        }
      },
    );
  }

  Future<void> loginAndNavigateToHome() async {
    try {
      // Map<String, dynamic> map = jsonDecode(utf8.decode(base64Decode(base64.normalize(
      //     widget.path ?? 'ewogICAgInVzZXJfZW1haWwiOiJ2aXZla0B5b3BtYWlsLmNvbSIsCiAgICAiZ3JvdXBfaWQiOiIiCn0='))));

      // debugPrint('===> USER EMAIL ' + map['user_email']);
      var userModel = FirebaseChatUser(
        deviceToken: '0',
        deviceType: kIsWeb
            ? 'w'
            : Platform.isIOS
                ? 'i'
                : 'A',
        isOnline: false,
        //await firebaseChatManager.fetchUserId(emailController.text.trim()),
        userEmail: 'james@yopmail.com',
        password: '111111',
        createdAt: generateUTC(DateTime.now().toUtc()),
      );

      User? user = await firebaseChatManager.firebaseUserLogin(userModel);
      if (user != null) {
        appDB.currentUserId = userModel.userId.toString();
        appDB.isLogin = true;

        appDB.user = (await firebaseChatManager.getUserDetails(userModel.userId.toString()))!;

        debugPrint('LOGGED IN USER ${appDB.user?.toJson()}');

        setState(() {});
      }
    } on Exception catch (e) {
      // showLoading.value = false;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email or password is invalid! Please try again.'),
        duration: const Duration(seconds: 2),
      ));
      debugPrint('Error In Firebase $e');
    }
  }

  Future<void> getPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized && appDB.currentUserId.isNotEmpty) {
      Future.delayed(
        const Duration(seconds: 5),
        () {
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          messaging.getToken().then((String? token) {
            print("Firebase token: $token");

            firebaseChatManager.updateDeviceToken(appDB.currentUserId);
          }).catchError((error) {
            print("Error getting Firebase token: $error");
          });

          debugPrint('TOKEN UPDATED :  ${appDB.currentUserId}');
        },
      );
    }
    debugPrint('Push Messaging token :  ${appDB.fcmToken}');
  }

  void messageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification?.body}');

        _controller.notificationCount.value += 1;
        debugPrint('NOTIFICATION COUNT = ${_controller.notificationCount.value}');
        if (message.data['is_group'] != null) {
          message.data['is_group'] = message.data['is_group'] == 'true' ? true : false;
        } else {
          message.data['is_group'] = false;
        }
        var data = ChatMessage.fromJson(message.data);
        data.title = message.notification?.title;
        data.body = message.notification?.body;

        _controller.setNotificationData(data);

        if (MediaQuery.sizeOf(context).width >= 600)
          showDialog(
            context: context,
            barrierColor: AppColor.transparent,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 3), () {
                Navigator.of(context).pop(true);
              });
              return _showNotification(context, message);
            },
          );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp==> Got a onMessageOpenedApp ');
      print('onMessageOpenedApp==> Message data: ${message.data}');
      print('onMessageOpenedApp==> Message also contained a notification: ${message.notification?.body}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  }

  Widget _showNotification(BuildContext context, RemoteMessage message) {
    return GestureDetector(
      onTap: () {
        debugPrint('TAG==> ${message.data['tag']}');
        if (message.data['tag'] == 'new_chat_message') {
          if (message.data['is_group'] != null) {
            message.data['is_group'] = message.data['is_group'] == 'true' ? true : false;
          } else {
            message.data['is_group'] = false;
          }
          _controller.selectedItem?.value = ChatMessage.fromJson(message.data);
          setState(() {});
          debugPrint('SELECTED ITEM => ${_controller.selectedItem?.toJson()}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: context.width - 200,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey[100]!, blurRadius: 10, spreadRadius: 5)],
            ),
            child: Row(
              children: [
                Image.asset(
                  Assets.imageNotification,
                  height: 40,
                  width: 40,
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.notification?.title ?? '', style: textMedium),
                      SizedBox(
                        height: 10,
                      ),
                      Text(message.notification?.body ?? '', style: textMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
    print('_firebaseBackgroundMessageHandler==> Got a onMessageOpenedApp ');
    print('_firebaseBackgroundMessageHandler==> Message data: ${message.data}');
    print('_firebaseBackgroundMessageHandler==> Message also contained a notification: ${message.notification?.body}');
  }
}

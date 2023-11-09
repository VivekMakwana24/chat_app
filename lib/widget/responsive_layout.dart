import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gotms_chat/core/db/app_db.dart';
import 'package:gotms_chat/generated/assets.dart';
import 'package:gotms_chat/main.dart';
import 'package:gotms_chat/ui/home/controller/notification_controller.dart';
import 'package:gotms_chat/ui/web/widgets/notification_icon.dart';
import 'package:gotms_chat/util/date_time_helper.dart';
import 'package:gotms_chat/util/firebase_chat_manager/constants/firebase_collection_enum.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/chat_message.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:gotms_chat/values/colors.dart';
import 'package:gotms_chat/values/constants.dart';
import 'package:gotms_chat/values/style.dart';
import 'package:velocity_x/velocity_x.dart';

class ResponsiveLayout extends StatefulWidget {
  final String? queryParam;
  final Widget webScreenLayout;
  final Widget? tabletScreenLayout;
  final Widget? mobileScreenLayout;

  ResponsiveLayout({
    super.key,
    this.queryParam,
    required this.webScreenLayout,
    this.tabletScreenLayout,
    this.mobileScreenLayout,
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
    /*if (!appDB.isLogin) {
    } else {
      debugPrint('<====USER ALREADY LOGGEDIN===>');
      Map<String, dynamic>? loginMap;
      debugPrint('widget.queryParam ${widget.queryParam}');
      debugPrint('widget.queryParam?.isNotEmpty ${widget.queryParam?.isNotEmpty}');
      if (widget.queryParam != null) {
        var decoded = utf8.decode(
          base64Decode(
            base64.normalize(widget.queryParam ??
                'ewogICAgInVzZXJfZW1haWwiOiJ2aXZla0B5b3BtYWlsLmNvbSIsCiAgICAiZ3JvdXBfaWQiOiIiCn0='),
          ),
        );
        decoded = decoded.replaceAll("\n", '');
        debugPrint('===> USER decoded  $decoded');
        loginMap = jsonDecode(decoded.toString());
        chatID = loginMap?['chat_id'] ?? '';
        debugPrint('===> chatID $chatID');
      }
      debugPrint('Already Logged In as ${appDB.user?.userEmail}');
    }*/

    messageListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return widget.webScreenLayout;
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
      Map<String, dynamic>? loginMap;
      debugPrint('widget.queryParam ${widget.queryParam}');
      debugPrint('widget.queryParam?.isNotEmpty ${widget.queryParam?.isNotEmpty}');
      if (widget.queryParam != null) {
        var decoded = utf8.decode(
          base64Decode(
            base64.normalize(widget.queryParam ??
                'ewogICAgInVzZXJfZW1haWwiOiJ2aXZla0B5b3BtYWlsLmNvbSIsCiAgICAiZ3JvdXBfaWQiOiIiCn0='),
          ),
        );
        decoded = decoded.replaceAll("\n", '');
        debugPrint('===> USER decoded  $decoded');
        loginMap = jsonDecode(decoded.toString());
        debugPrint('===> USER EMAIL ${loginMap?['user_email']}');
        chatID = loginMap?['chat_id'] ?? '';
        debugPrint('===> chatID $chatID');
      }

      debugPrint(
          'CHECk DATA ==> as current email ${appDB.user?.userEmail} is equal to ${loginMap?['user_email'].toString().toLowerCase()}');

      if (appDB.isLogin) {
        if (loginMap?['user_email'] == null) return;
        if (appDB.user?.userEmail?.toLowerCase() != 'james@yopmail.com' &&
            appDB.user?.userEmail?.toLowerCase() == loginMap?['user_email'].toString().toLowerCase()) {
          debugPrint(
              'RETURNING DATA ==> as current email ${appDB.user?.userEmail} is equal to ${loginMap?['user_email'].toString().toLowerCase()}');

          appDB.user = (await firebaseChatManager.getUserDetails(appDB.user?.userId ?? ''))!;
          return;
        } else {
          debugPrint('MOVING FORWARD WITH LOGIN');
        }
      }

      var userModel = FirebaseChatUser(
        deviceToken: '0',
        deviceType: kIsWeb
            ? 'w'
            : Platform.isIOS
                ? 'i'
                : 'A',
        isOnline: false,
        //await firebaseChatManager.fetchUserId(emailController.text.trim()),
        userEmail: loginMap != null ? loginMap['user_email'] : 'james@yopmail.com',
        password: loginMap != null ? loginMap['password'] : '111111',
        createdAt: generateUTC(DateTime.now().toUtc()),
      );

      User? user = await firebaseChatManager.firebaseUserLogin(userModel);
      if (user != null) {
        appDB.currentUserId = userModel.userId.toString();
        appDB.isLogin = true;

        appDB.user = (await firebaseChatManager.getUserDetails(userModel.userId.toString()))!;

        if (appDB.user?.userName.isEmptyOrNull ?? false) {
          debugPrint(
              'USERNAME not found so inserting username : ${appDB.user?.userEmail?.substring(0, appDB.user?.userEmail?.indexOf('@')).replaceAll("@", '')}');
          firebaseChatManager.updateDataFirestore(
            FirebaseCollection.users.name,
            appDB.currentUserId,
            {
              'user_name': appDB.user?.userEmail?.substring(0, appDB.user?.userEmail?.indexOf('@')).replaceAll("@", ''),
            },
          );
        }

        debugPrint('LOGGED IN USER ${appDB.user?.toJson()}');

        setState(() {});
      }
    } on Exception catch (e) {
      // showLoading.value = false;

      /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email or password is invalid! Please try again.'),
        duration: const Duration(seconds: 2),
      ));*/
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

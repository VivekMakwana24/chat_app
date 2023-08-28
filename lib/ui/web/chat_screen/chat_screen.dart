import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/home/home_page.dart';
import 'package:flutter_demo_structure/ui/home/new_group/new_group_page.dart';
import 'package:flutter_demo_structure/ui/home/user_list_page.dart';
import 'package:flutter_demo_structure/ui/web/widgets/left_navbar.dart';
import 'package:flutter_demo_structure/util/date_time_helper.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/firebase_chat_user.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/export.dart';

class WebChatScreen extends StatefulWidget {
  final String? path;

  const WebChatScreen({
    super.key,
    this.path,
  });

  @override
  State<WebChatScreen> createState() => _WebChatScreenState();
}

class _WebChatScreenState extends State<WebChatScreen> {
  SelectedScreen selectedScreen = SelectedScreen.OneToOne;

  ValueNotifier<bool> _showLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    loginAndNavigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorData.white,
      body: ValueListenableBuilder(
        valueListenable: _showLoading,
        builder: (BuildContext context, bool isLoading, Widget? child) {
          return isLoading
              ? SizedBox(height: 40, width: 40, child: CircularProgressIndicator.adaptive()).wrapCenter()
              : appDB.user?.userId != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //LEFT NAV BAR
                        LeftNavBar(
                          selectedScreen: selectedScreen,
                          onScreenChange: (screen) {
                            selectedScreen = screen;
                            setState(() {});
                          },
                        ),
                        //DEVIDER
                        Container(
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: ColorData.lightGrey),
                              bottom: BorderSide(color: ColorData.lightGrey),
                            ),
                            color: ColorData.white,
                          ),
                        ),

                        //WEB PROFILE
                        Expanded(
                          child: selectedScreen == SelectedScreen.OneToOne
                              ? appDB.user != null
                                  ? HomePage()
                                  : CircularProgressIndicator.adaptive()
                              : appDB.user != null
                                  ? UserListPage(
                                      isForGroup: false,
                                      pageType: PageType.USERS,
                                    )
                                  : CircularProgressIndicator.adaptive(),
                        ),

                        /* //DEVIDER
            Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: ColorData.lightGrey),
                  bottom: BorderSide(color: ColorData.lightGrey),
                ),
                color: ColorData.white,
              ),
            ),*/

                        /*//WEB MESSAGE  SCREEN
            const Expanded(
              flex: 2,
              child: MessageScreen(),
            ),*/
                      ],
                    ).visiblity(!isLoading)
                  : SizedBox(height: 40, width: 40, child: CircularProgressIndicator.adaptive()).wrapCenter();
        },
      ),
    );
  }

  Future<void> loginAndNavigateToHome() async {
    try {
      // Map<String, dynamic> map = jsonDecode(utf8.decode(base64Decode(base64.normalize(
      //     widget.path ?? 'ewogICAgInVzZXJfZW1haWwiOiJ2aXZla0B5b3BtYWlsLmNvbSIsCiAgICAiZ3JvdXBfaWQiOiIiCn0='))));

      // debugPrint('===> USER EMAIL ' + map['user_email']);
      _showLoading.value = true;
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
      _showLoading.value = false;
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
}

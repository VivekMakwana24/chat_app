import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/auth/login/login_page.dart';
import 'package:flutter_demo_structure/ui/home/controller/notification_controller.dart';
import 'package:flutter_demo_structure/ui/web/widgets/notification_icon.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

enum SelectedScreen { OneToOne, Groups }

class LeftNavBar extends StatefulWidget {
  SelectedScreen selectedScreen;
  final Function(SelectedScreen) onScreenChange;

  LeftNavBar({
    required this.selectedScreen,
    required this.onScreenChange,
    super.key,
  });

  @override
  State<LeftNavBar> createState() => _LeftNavBarState();
}

class _LeftNavBarState extends State<LeftNavBar> {
  final _controller = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    messageListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 80,
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          //LOGO
          SvgPicture.asset(
            Assets.svgsChatLogo,
            height: 40,
          ),
          50.heightBox,

          //ICONS
          Column(
            children: [
              //CHAT ICON
              InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  if (widget.selectedScreen == SelectedScreen.OneToOne) return;
                  widget.selectedScreen = SelectedScreen.OneToOne;
                  widget.onScreenChange(widget.selectedScreen);
                  setState(() {});
                },
                child: SvgPicture.asset(
                  color: widget.selectedScreen == SelectedScreen.OneToOne ? ColorData.primary : ColorData.grey,
                  Assets.svgsChat,
                  height: 30,
                ),
              ),
              40.heightBox,

              //GROUP ICON
              InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  if (widget.selectedScreen == SelectedScreen.Groups) return;

                  widget.selectedScreen = SelectedScreen.Groups;
                  widget.onScreenChange(widget.selectedScreen);
                  setState(() {});
                },
                child: SvgPicture.asset(
                  color: widget.selectedScreen == SelectedScreen.Groups ? ColorData.primary : ColorData.grey,
                  Assets.svgsUsers,
                  height: 30,
                ),
              ),

              40.heightBox,

              //NOtification ICON
              NotificationIcon()
            ],
          ),

          //SPACCER

          const Spacer(),

          //LOGOUT ICON
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              firebaseChatManager.logoutUser();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (route) => false);
            },
            child: SvgPicture.asset(
              Assets.svgsLogout,
              height: 30,
            ),
          ).visiblity(false),
          30.heightBox,
        ],
      ),
    );
  }

  void messageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification?.body}');
      }
    });
  }
}

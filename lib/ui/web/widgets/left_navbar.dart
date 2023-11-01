import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gotms_chat/core/db/app_db.dart';
import 'package:gotms_chat/generated/assets.dart';
import 'package:gotms_chat/main.dart';
import 'package:gotms_chat/ui/auth/login/login_page.dart';
import 'package:gotms_chat/ui/home/controller/notification_controller.dart';
import 'package:gotms_chat/ui/web/widgets/notification_icon.dart';
import 'package:gotms_chat/util/hover_builder.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

enum SelectedScreen { RecentChat, users, Groups }

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
      child: SingleChildScrollView(
        child: Column(
          children: [
            20.verticalSpace,
            //LOGO
            Center(
              child: HoverBuilder(
                builder: (bool isHovered) {
                  return SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            Assets.svgsChatLogo,
                            height: 40,
                          ),
                        ),
                        if (isHovered)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                border: Border.all(color: AppColor.blackColor),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                appDB.user?.userName ?? '',
                                style: textRegular10.copyWith(color: AppColor.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            30.heightBox,

            //ICONS
            Column(
              children: [
                //CHAT ICON
                InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () {
                    if (widget.selectedScreen == SelectedScreen.RecentChat) return;
                    widget.selectedScreen = SelectedScreen.RecentChat;
                    widget.onScreenChange(widget.selectedScreen);
                    setState(() {});
                  },
                  child: SvgPicture.asset(
                    color: widget.selectedScreen == SelectedScreen.RecentChat ? ColorData.primary : ColorData.grey,
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
                ), //User ICON
                40.heightBox,

                InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () {
                    if (widget.selectedScreen == SelectedScreen.users) return;

                    widget.selectedScreen = SelectedScreen.users;
                    widget.onScreenChange(widget.selectedScreen);
                    setState(() {});
                  },
                  child: Image.asset(
                    color: widget.selectedScreen == SelectedScreen.users ? ColorData.primary : ColorData.grey,
                    Assets.imageIcUsersingle,
                    height: 30,
                  ),
                ),

                40.heightBox,

                //NOtification ICON
                NotificationIcon()
              ],
            ),

            //SPACCER

            // const Spacer(),

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

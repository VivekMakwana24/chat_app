import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/model/notification_data.dart';
import 'package:flutter_demo_structure/ui/auth/login/login_page.dart';
import 'package:flutter_demo_structure/ui/home/controller/notification_controller.dart';
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
  final _controller = Get.put(NotificationController());

  int count = 0;

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
              SizedBox(
                height: 40,
                width: 40,
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      count = 0;
                    });

                    showDialog(
                      context: context,
                      builder: (context) {
                        return _notificationDialog();
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          color: widget.selectedScreen == SelectedScreen.Groups ? ColorData.primary : ColorData.grey,
                          Assets.imageNotification,
                          height: 30,
                        ),
                      ),
                      if (count != 0)
                        Positioned(
                          right: 0,
                          top: -2,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: ColorData.primary),
                            child: Text(
                              count.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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

  Dialog _notificationDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Center(
                  child: Text(
                    'Notifications',
                    style: textBold,
                  ),
                ),
                Positioned(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset(Assets.svgsIcClose),
                  ),
                  right: 0,
                  bottom: 0,
                  top: 0,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: _controller.getNotificationList?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    ChatMessage? itemData = _controller.getNotificationList?[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
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
                                Text(itemData?.title ?? '', style: textMedium),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(itemData?.body ?? '', style: textMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).addGestureTap(() {
                    });
                  },
                ),
              ),
            )
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
        count += 1;
        setState(() {});
        debugPrint('NOTIFICATION COUNT = $count');
        /*var data = ChatMessage(
          title: message.notification?.title,
          message: message.notification?.body,
        );
*/
        var data = ChatMessage.fromJson(message.data);
        data.title = message.notification?.title;
        data.body = message.notification?.body;

        _controller.setNotificationData(data);
      }
    });
  }
}

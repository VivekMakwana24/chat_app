import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/ui/home/controller/notification_controller.dart';
import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/extensions/export.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:flutter_demo_structure/generated/assets.dart';

class NotificationIcon extends StatelessWidget {
  NotificationIcon({super.key});

  var _controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () {
          _controller.notificationCount.value = 0;

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
                color: ColorData.primary,
                Assets.imageNotification,
                height: 30,
              ),
            ),
            Positioned(
              right: 0,
              top: -2,
              child: Obx(
                () => Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: ColorData.primary),
                  child: Text(
                    _controller.notificationCount.value.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ).visiblity(_controller.notificationCount.value > 0),
              ),
            ),
          ],
        ),
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
                                if (itemData?.isGroup ?? false) ...[
                                  Text(itemData?.groupName ?? '', style: textBold),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                                Text(itemData?.title ?? '', style: textMedium),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(itemData?.body ?? '', style: textRegular),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

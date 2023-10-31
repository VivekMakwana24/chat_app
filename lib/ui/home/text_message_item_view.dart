import 'package:flutter/material.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/chat_message.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';

class TextMessageItemView extends StatelessWidget {
  final ChatMessage message;

  const TextMessageItemView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: message.isLeftSide ? AppColor.primaryColor : AppColor.primaryColor,
              /* border: Border.all(
                color: message.isLeftSide
                    ? AppColor.whiteShade
                    : message.isFailed
                        ? AppColor.redColor
                        : AppColor.springGreenColor,
              ),*/
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  message.isLeftSide ? 0.r : 15.r,
                ),
                bottomRight: Radius.circular(
                  message.isLeftSide ? 15.r : 0.r,
                ),
                topLeft: Radius.circular(
                  15.r,
                ),
                topRight: Radius.circular(
                  15.r,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0.h),
              child: Text(
                (message.message ?? ''),
                style: textRegular.copyWith(
                  fontSize: 14.sm,
                  color: message.isLeftSide ? AppColor.primaryColor : AppColor.primaryColor,
                ),
              ),
            ),
          ),
          if (message.isFailed) 8.h.verticalSpace,
        ],
      ),
    );
  }
}

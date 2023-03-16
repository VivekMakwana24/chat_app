import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/values/string_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenPlaceOrder extends StatefulWidget {
  String? message;
  IconData? icon;

  ScreenPlaceOrder({this.message, this.icon});

  @override
  _ScreenPlaceOrderState createState() => _ScreenPlaceOrderState();
}

class _ScreenPlaceOrderState extends State<ScreenPlaceOrder> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            widget.icon ?? Icons.info_outline,
            color: AppColor.greyColor,
          ),
          SizedBox(height: 10.h),
          Text(
            widget.message ?? StringConstant.dataNotFound,
            style: textBold.copyWith(color: AppColor.greyColor),
          )
        ],
      ),
    );
  }
}

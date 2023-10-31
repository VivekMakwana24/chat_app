import 'package:flutter/material.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButtonInverse extends StatelessWidget {
  String label;
  Function() callback;
  double? elevation;
  double? height;
  double? radius;
  double? padding;
  bool buttonColor;

  AppButtonInverse(this.label, this.callback,
      {double elevation = 0.0, this.height, this.radius, this.padding, this.buttonColor = false}) {
    this.elevation = elevation;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: MaterialButton(
        elevation: this.elevation,
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        onPressed: callback,
        child: Text(
          label,
          style: textBold.copyWith(color: AppColor.white, fontSize: 16.spMin),
        ),
        color: buttonColor ? AppColor.primaryColor : AppColor.primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColor.primaryColor),
          borderRadius: BorderRadius.all(Radius.circular(radius ?? kBorderRadius)),
        ),
      ),
    );
  }
}

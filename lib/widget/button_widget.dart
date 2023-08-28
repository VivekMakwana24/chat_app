import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  String label;
  VoidCallback callback;
  double? elevation;
  double? height;
  double? radius;
  double? padding;
  bool buttonColor;
  Color? color;

  AppButton(
    this.label,
    this.callback, {
    double elevation = 0.0,
    this.height,
    this.radius,
    this.padding,
    this.buttonColor = false,
    this.color = AppColor.primaryColor,
  }) {
    this.elevation = elevation;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: MaterialButton(
        elevation: this.elevation,
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        onPressed: callback,
        child: Text(
          label,
          style: textMedium.copyWith(
            color: buttonColor ? AppColor.white : AppColor.white,
            fontSize: 12.spMin,
          ),
        ),
        color: buttonColor ? Colors.black : AppColor.transparent,
        shape: RoundedRectangleBorder(
          side: buttonColor ? BorderSide.none : BorderSide(color: Colors.white, width: 2.w),
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        ),
      ),
    );
  }
}

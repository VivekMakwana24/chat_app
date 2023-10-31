import 'package:flutter/material.dart';
import 'package:gotms_chat/values/export.dart';
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
      height: height,
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
        color: buttonColor ? color : AppColor.primaryColorDark,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(radius ?? 10),
          ),
        ),
      ),
    );
  }
}

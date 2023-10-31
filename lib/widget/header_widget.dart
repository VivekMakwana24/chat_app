import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:gotms_chat/res.dart';
import 'package:gotms_chat/values/extensions/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarWidget extends StatefulWidget {
  Widget? actionMenu;
  double paddingStart;
  Color backgroundColor;

  AppBarWidget({this.actionMenu, this.paddingStart = 10.0, this.backgroundColor = Colors.white});

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

var paddingTop = (kToolbarHeight - 20).toDouble();

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      padding: EdgeInsets.only(top: paddingTop),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            Res.back,
            height: 20.h,
            width: 80.w,
          ).addGestureTap(() {
            Navigator.maybePop(context);
          }).wrapPadding(padding: EdgeInsets.only(left: widget.paddingStart)),
          Container().expand(1),
          widget.actionMenu ?? Container()
        ],
      ),
    );
  }
}

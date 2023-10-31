import 'package:flutter/material.dart';
import 'package:gotms_chat/res.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseAppBar extends StatefulWidget implements PreferredSizeWidget {
  late String? title;
  bool centerTitle = false;
  late Color? backgroundColor;
  late double? elevations;
  List<Widget>? action;
  bool leadingIcon = false;
  bool showTitle = false;
  Function()? backAction;
  Widget? titleWidget;
  Widget? leadingWidget;
  Color? leadingWidgetColor;
  Color? titleWidgetColor;

  BaseAppBar({
    this.title,
    this.centerTitle = true,
    this.backgroundColor = AppColor.white,
    this.elevations = 0.0,
    this.action,
    this.leadingIcon = false,
    this.showTitle = false,
    this.backAction,
    this.titleWidget,
    this.leadingWidget,
    this.leadingWidgetColor = AppColor.blackColor,
    this.titleWidgetColor = AppColor.blackColor,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  }) : assert(title == null || titleWidget == null, "Title and Title widget both can't be null");

  /*BaseAppBar(String title,
      {Key? key,
      Color backgroundColor = AppColor.primaryColor,
      bool centerTitle = true,
      List<Widget>? action,
      Widget? titleWidget,
      Widget? leadingWidget,
      Color? leadingWidgetColor,
      Function()? backAction,
      double elevations = 0.0,
      bool leadingIcon = false})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key) {
    this.title = title;
    this.centerTitle = centerTitle;
    this.backgroundColors = backgroundColor;
    this.action = action;
    this.leadingIcon = leadingIcon;
    this.elevations = elevations;
    this.backAction = backAction;
    this.titleWidget = titleWidget;
    this.leadingWidget = leadingWidget;
    this.leadingWidgetColor = leadingWidgetColor;
  }
*/

  @override
  final Size preferredSize; // default is 56.0

  @override
  _BaseAppBarState createState() => _BaseAppBarState();
}

class _BaseAppBarState extends State<BaseAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: widget.centerTitle,
      bottom: PreferredSize(
        preferredSize: Size(context.width, 1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ColorData.lightGrey),
            ),
            color: ColorData.white,
          ),
        ),
      ),
      title: !widget.showTitle
          ? SizedBox.shrink()
          : widget.titleWidget ??
              Text(
                widget.title!,
                style: textBold.copyWith(fontSize: 19.spMin, color: widget.titleWidgetColor),
              ),
      backgroundColor: widget.backgroundColor != null ? widget.backgroundColor : AppColor.white,
      elevation: widget.elevations,
      automaticallyImplyLeading: false,
      //brightness: Brightness.dark,

      leading: widget.leadingIcon
          ? widget.leadingWidget ??
              IconButton(
                icon: Image.asset(
                  Res.back,
                  height: 20.0,
                  width: 24.0,
                  color: widget.leadingWidgetColor,
                ),
                onPressed: () {
                  if (widget.backAction != null)
                    widget.backAction!.call();
                  else
                    Navigator.maybePop(context);
                },
              )
          : null,
      iconTheme: IconThemeData(color: Colors.black),
      actions: widget.action,
    );
  }
}

class OverLapsWidget extends StatelessWidget {
  const OverLapsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15.67.w,
      height: 17.96.h,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 9.w,
              height: 9.h,
              margin: EdgeInsets.only(top: 10, right: 22.0),
              child: Container(
                width: 9.h,
                height: 9.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.toolbarColor,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(fontSize: 5.spMin),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

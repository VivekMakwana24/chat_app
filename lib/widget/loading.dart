import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Loading extends StatefulWidget {
  final bool backgroundTransparent;
  final String? message;
  final bool status;
  final Widget child;

  const Loading(
      {Key? key,
      required this.status,
      required this.child,
      this.message,
      this.backgroundTransparent = false})
      : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[widget.child, _loading(widget.status)]);
  }

  Widget _loading(bool loading) {
    return loading == true
        ? Container(
            height: 1.sh,
            width: 1.sw,
            alignment: Alignment.center,
            color:
                widget.backgroundTransparent == true ? Colors.grey : Colors.grey.withOpacity(0.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                )
              ],
            ),
          )
        : Container();
  }
}

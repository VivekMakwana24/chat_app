import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/values/export.dart';

enum MessageType { INFO, ERROR, WARNING }

Flushbar? _flushBar;

showMessage(
  String message, {
  MessageType type = MessageType.INFO,
}) {
  debugPrint("ShowMessage: $message");

  try {
    if (_flushBar != null) _flushBar!.dismiss();
    _flushBar = Flushbar(
      messageText: Text(
        message,
        style: textBold.copyWith(color: AppColor.white),
      ),
      animationDuration: Duration.zero,
      backgroundColor: AppColor.primaryColor,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    )..show(NavigationService.navigatorKey.currentContext!);
  } catch (onError) {
    debugPrint(onError.toString());
  }
}

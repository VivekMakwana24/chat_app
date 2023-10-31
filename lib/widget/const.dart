import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gotms_chat/core/navigation/navigation_service.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:velocity_x/velocity_x.dart';

var customDateFormat = 'dd/MM/yyyy HH:mm';

Size displaySize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double height(BuildContext context) {
  return displaySize(context).height;
}

double width(BuildContext context) {
  return displaySize(context).width;
}

showErrorMessage(String? message, {BuildContext? context}) {
  ScaffoldMessenger.of(context ?? NavigationService.navigatorKey.currentContext!).showSnackBar(
    SnackBar(
      content: Text(
        message ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

showSuccessMessage(String? message) {
  ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
    SnackBar(
      content: Text(
        message ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 1),
    ),
  );
}

showLoader({Color? backgroundColor}) {
  return SizedBox(
    height: 30,
    width: 30,
    child: CircularProgressIndicator.adaptive(
      backgroundColor: Platform.isAndroid ? ColorData.primary : backgroundColor ?? Colors.grey,
    ),
  ).centered();
}

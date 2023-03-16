import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/style.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColor.primaryColor,
  accentColor: AppColor.brownColor,
  scaffoldBackgroundColor: const Color(0xfff9f9f9),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    color: AppColor.primaryColor,
    textTheme: TextTheme(
      headline6: textBold,
    ),
    iconTheme: IconThemeData(color: AppColor.white, size: 30.0),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColor.textBackgroundColor,
    disabledColor: AppColor.textBackgroundColor,
  ),
  textTheme: GoogleFonts.ralewayTextTheme(),
);

import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColor.primaryColor,
  scaffoldBackgroundColor: const Color(0xffffffff),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    color: AppColor.primaryColor,
    iconTheme: IconThemeData(color: AppColor.white, size: 30.0),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColor.textBackgroundColor,
    disabledColor: AppColor.textBackgroundColor,
  ),
  textTheme: GoogleFonts.ralewayTextTheme(),
);

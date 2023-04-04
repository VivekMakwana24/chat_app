import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/core/navigation/routes.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/ui/navbar/navbar.dart';
import 'package:flutter_demo_structure/ui/web/chat_screen/chat_screen.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/widget/responsive_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  initState() {
    initSetting();
    super.initState();
  }

  Future<void> initSetting() async {
    // bool isAuthenticated = await AuthService.authenticateUser();
    if (true) {
      Timer(Duration(seconds: 2), () {
        if (appDB.isLogin)
          navigator.pushReplacementNamed(RouteName.homePage);
        else {
          navigator.pushReplacementNamed(RouteName.loginPage);
        }
      });
    } else {
      Timer(Duration(seconds: 2), () {
        if (!appDB.isLogin)
          navigator.pushReplacementNamed(RouteName.lineChart);
        else {
          navigator.pushReplacementNamed(RouteName.homePage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              Assets.svgsLogo,
              height: context.height * .106,
            ),
          ),
          40.heightBox,
          Text(
            "Transport Management System",
            style: GoogleFonts.nunito(
              fontSize: context.height * .026,
              fontWeight: FontWeight.w800,
              color: ColorData.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

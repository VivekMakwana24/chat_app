import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/core/navigation/routes.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/ui/navbar/navbar.dart';
import 'package:flutter_demo_structure/ui/web/chat_screen/chat_screen.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/widget/responsive_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    if (appDB.isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            webScreenLayout: WebChatScreen(),
            tabletScreenLayout: MyBottomNavigationBar(),
            mobileScreenLayout: MyBottomNavigationBar(),
          ),
        ),
      );
    } else {
      // navigator.pushReplacementNamed(RouteName.loginPage);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            webScreenLayout: WebChatScreen(),
            tabletScreenLayout: MyBottomNavigationBar(),
            mobileScreenLayout: MyBottomNavigationBar(),
          ),
        ),
      );
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
              Assets.svgsSplashLogo,
              height: context.height * .206,
            ),
          ),
          40.heightBox,
        ],
      ),
    );
  }
}

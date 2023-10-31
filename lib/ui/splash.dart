import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gotms_chat/generated/assets.dart';
import 'package:gotms_chat/ui/navbar/navbar.dart';
import 'package:gotms_chat/ui/web/chat_screen/chat_screen.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:gotms_chat/widget/responsive_layout.dart';
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
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResponsiveLayout(
          webScreenLayout: WebChatScreen(),
          tabletScreenLayout: MyBottomNavigationBar(),
          mobileScreenLayout: MyBottomNavigationBar(),
        ),
      ),
    );*/
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

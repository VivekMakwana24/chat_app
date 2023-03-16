import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/core/db/app_db.dart';
import 'package:flutter_demo_structure/core/navigation/navigation_service.dart';
import 'package:flutter_demo_structure/core/navigation/routes.dart';
import 'package:flutter_demo_structure/util/biometric_service.dart';
import 'package:flutter_demo_structure/values/colors.dart';

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
    return SafeArea(
      child: Container(
        color: AppColor.white,
        child: Center(
          child: FlutterLogo(),
        ),
      ),
    );
  }
}

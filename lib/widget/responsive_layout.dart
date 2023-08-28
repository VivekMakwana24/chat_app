import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget webScreenLayout;
  final Widget tabletScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout({
    super.key,
    required this.webScreenLayout,
    required this.tabletScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return webScreenLayout;
        } else if (constraints.maxWidth < 580) {
          return Image.asset(
            color: ColorData.primary,
            Assets.imageNotification,
            height: 30,
          );
        } else {
          return webScreenLayout;
        }
      },
    );
  }
}

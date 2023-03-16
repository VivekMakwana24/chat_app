import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/export.dart';

class MyBullet extends StatelessWidget {
  final double padding;

  const MyBullet({this.padding = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.0,
      width: 5.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.osloGray.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    ).wrapPaddingHorizontal(padding);
  }
}

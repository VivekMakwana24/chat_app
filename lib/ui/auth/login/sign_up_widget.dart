import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/res.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_demo_structure/values/string_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpWidget extends StatelessWidget {
  final bool fromLogin;
  final Function() onTap;

  const SignUpWidget({required this.fromLogin, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColor.hamptonColor.withOpacity(0.349),
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            fromLogin ? Res.add_user : Res.user,
            height: 28.0,
            width: 28.0,
          ),
          4.0.VBox,
          Text(
            fromLogin ? StringConstant.dontHaveAccount : StringConstant.alreadyHaveAccount,
            style: textMedium.copyWith(
              color: AppColor.brownColor,
              fontSize: 16.sp,
            ),
          ),
          4.0.VBox,
          Text(
            fromLogin ? StringConstant.signUp.toUpperCase() : StringConstant.login.toUpperCase(),
            style: textBold.copyWith(
              color: AppColor.primaryColor,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    ).wrapPaddingHorizontal(20.w).addGestureTap(onTap);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:gotms_chat/values/string_constants.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String subTitle;
  final String buttonOkText;
  final String buttonCancelText;
  final Function()? onTapOkCallback;
  final Function()? onTapCancelCallback;

  CustomAlertDialog(
      {this.title = kConfirm,
      this.subTitle = kLogoutMsg,
      this.buttonOkText = StringConstant.ok,
      this.buttonCancelText = StringConstant.cancel,
      this.onTapOkCallback,
      this.onTapCancelCallback});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColor.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: Text(
                this.title,
                style: textBold,
              ),
            ),
            Divider(
              height: 0,
              thickness: 1.h,
              color: AppColor.primaryColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 10.w),
              child: Text(
                this.subTitle,
                textAlign: TextAlign.center,
                style: textMedium.copyWith(fontSize: 20.spMin),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (onTapCancelCallback != null) onTapCancelCallback!();
                    },
                    child: LayoutBuilder(builder: (context, snapshot) {
                      return Container(
                        width: 100.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: AppColor.primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            this.buttonCancelText,
                            style: textBold.copyWith(color: AppColor.white),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onTapOkCallback!();
                    },
                    child: LayoutBuilder(builder: (context, snapshot) {
                      return Container(
                        width: 100.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: AppColor.primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            this.buttonOkText,
                            style: textBold.copyWith(color: AppColor.white),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

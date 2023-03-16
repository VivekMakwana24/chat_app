import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RadioButton<T> extends StatelessWidget {
  RadioButton({
    Key? key,
    required this.value,
    required this.caption,
    required this.groupValue,
    required this.onChanged,
    this.width,
    this.height,
    this.decoration,
  })  : assert(value != null),
        assert(caption != null),
        assert(groupValue != null),
        assert(onChanged != null),
        super(key: key);

  final T value;
  final T groupValue;
  final String caption;
  final Function(T)? onChanged;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged!(value);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6, left: 6),
        width: width ?? 24.w,
        height: height ?? 24.h,
        decoration: decoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: value == groupValue ? AppColor.primaryColor : AppColor.colorHint,
            ),
        child: Center(
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: value == groupValue ? Colors.white : Colors.red),
          ),
        ),
      ),
    );
  }
}

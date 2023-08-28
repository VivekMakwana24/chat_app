import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomOtpView extends StatefulWidget {
  final String lastPin;
  final int fields;
  final Function(String) onSubmit;
  final double fontSize;
  final isTextObscure;
  final bool isClear;
  final Function(String) onTap;

  CustomOtpView({
    this.lastPin = '',
    this.fields: 4,
    required this.onSubmit,
    required this.onTap,
    this.fontSize: 20.0,
    this.isTextObscure: false,
    this.isClear: false,
  }) : assert(fields > 0);

  @override
  State createState() {
    return CustomOtpViewState();
  }
}

class CustomOtpViewState extends State<CustomOtpView> {
  late List<String> _pin;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _textControllers;
  Widget textFields = Container();

  @override
  void initState() {
    super.initState();
    _pin = List.generate(widget.fields, (index) => "");
    _focusNodes = List.generate(widget.fields, (index) => FocusNode());
    _textControllers = List.generate(widget.fields, (index) => TextEditingController(text: ""));
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        if (widget.lastPin != null) {
          for (var i = 0; i < widget.lastPin.length; i++) {
            _pin[i] = widget.lastPin[i];
          }
        }
        textFields = generateTextFields(context);
      });
    });
    if (widget.isClear) {
      clearTextFields();
    }
  }

  @override
  void dispose() {
    _textControllers.forEach((TextEditingController t) => t.dispose());
    _focusNodes.forEach((FocusNode f) => f.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    }, growable: false);

    if (_pin.first != null) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      verticalDirection: VerticalDirection.down,
      children: textFields,
    );
  }

  void clearTextFields() {
    _textControllers.forEach((TextEditingController tEditController) => tEditController.clear());
    _pin.clear();
  }

  Widget buildTextField(int i, BuildContext context) {
    if (_focusNodes[i] == null) {
      _focusNodes[i] = FocusNode();
    }
    if (_textControllers[i] == null) {
      _textControllers[i] = TextEditingController();
      if (widget.lastPin != null) {
        _textControllers[i].text = widget.lastPin[i];
      }
    }
    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {}
    });

    final String lastDigit = _textControllers[i].text;
    return Container(
      height: 70,
      width: 60,
      decoration: BoxDecoration(shape: BoxShape.rectangle),
      child: Center(
        child: TextField(
          cursorWidth: 0,
          controller: _textControllers[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          maxLength: 1,
          style: textBold.copyWith(fontSize: 45.spMin, color: AppColor.primaryColor),
          focusNode: _focusNodes[i],
          obscureText: widget.isTextObscure,
          decoration: InputDecoration(
            hintStyle: textBold.copyWith(fontSize: 45.spMin, color: Color(0xffCBCDD1)),
            counterText: "",
            hintText: "•",
            contentPadding: EdgeInsets.zero,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
              borderSide: BorderSide(
                color: AppColor.santasGray.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
              borderSide: BorderSide(
                color: AppColor.santasGray.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
              borderSide: BorderSide(
                color: AppColor.santasGray.withOpacity(0.5),
                width: 1.0,
              ),
            ),
          ),
          onChanged: (String str) {
            setState(() {
              _pin[i] = str;
            });

            widget.onTap(_pin.join());

            if (i + 1 != widget.fields) {
              _focusNodes[i].unfocus();
              if (lastDigit != null && _pin[i] == '') {
                FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
              } else {
                FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
              }
            } else {
              _focusNodes[i].unfocus();
              if (lastDigit != null && _pin[i] == '') {
                FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
              }
            }
            if (_pin.every((String digit) => digit != null && digit != '')) {
              widget.onSubmit(_pin.join());
            }
          },
          onSubmitted: (String str) {
            if (_pin.every((String digit) => digit != null && digit != '')) {
              widget.onSubmit(_pin.join());
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textFields;
  }
}

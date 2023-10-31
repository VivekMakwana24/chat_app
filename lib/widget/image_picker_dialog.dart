import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:gotms_chat/values/string_constants.dart';
import 'package:gotms_chat/widget/media_picker.dart';
import 'package:images_picker/images_picker.dart';

class MediaPickerDialog extends StatelessWidget {
  final MediaPickerHandler listener;
  final AnimationController controller;
  late BuildContext context;

  MediaPickerDialog(this.listener, this.controller, {Key? key}) : super(key: key);

  late Animation<double> _drawerContentsOpacity;
  late Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = CurvedAnimation(
      parent: ReverseAnimation(controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => SlideTransition(
        position: _drawerDetailsPosition,
        child: FadeTransition(
          opacity: ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }

  startTime() async {
    var _duration = const Duration(milliseconds: 200);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    controller.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Material(
      type: MaterialType.transparency,
      child: Opacity(
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.only(left: 30, top: 0.0, right: 30, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () => listener.openCamera(),
                child: roundedButton(
                  StringConstant.camera,
                  const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  AppColor.primaryColor,
                  AppColor.white,
                ),
              ),
              GestureDetector(
                onTap: () => listener.openGallery(),
                child: roundedButton(
                  StringConstant.gallery,
                  const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  AppColor.primaryColor,
                  AppColor.white,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => dismissDialog(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 0.0, right: 30, bottom: 20),
                  child: roundedButton(
                    StringConstant.cancel,
                    const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    AppColor.primaryColor,
                    AppColor.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roundedButton(String buttonLabel, EdgeInsets margin, Color bgColor, Color textColor) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: margin,
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.5),
            offset: const Offset(0.5, 2.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: textBold.copyWith(color: textColor),
      ),
    );
  }
}

class MediaPickerHandler {
  late MediaPickerDialog imagePicker;
  late final AnimationController _controller;
  late final MediaPickerListener _listener;
  late PickFileType _pickFileType;
  int _maxPickFileCount = 1;
  CropOption? _cropOption;

  MediaPickerHandler(this._listener, this._controller);

  Future<void> openCamera() async {
    imagePicker.dismissDialog();
    List<Media?>? pickedFiles;
    if (_pickFileType == PickFileType.image) {
      pickedFiles = await MediaPicker.pickImageFromCamera(cropOption: _cropOption);
    } else {
      pickedFiles = await MediaPicker.pickVideoFromCamera();
    }
    _listener.pickedFiles(pickedFiles, _pickFileType);
  }

  Future<void> openGallery() async {
    imagePicker.dismissDialog();
    List<Media?>? pickedFiles;
    if (_pickFileType == PickFileType.image) {
      pickedFiles =
          await MediaPicker.pickImageFromGallery(maxPickFileCount: _maxPickFileCount, cropOption: _cropOption);
    } else {
      pickedFiles = await MediaPicker.pickVideoFromGallery(maxPickFileCount: _maxPickFileCount);
    }
    _listener.pickedFiles(pickedFiles, _pickFileType);
  }

  void init() {
    imagePicker = MediaPickerDialog(this, _controller);
    imagePicker.initState();
  }

  showDialog(
    BuildContext context,
    PickFileType pickFileType, {
    int maxPickFileCount = 1,
    CropOption? cropOption,
  }) {
    _pickFileType = pickFileType;
    _cropOption = cropOption;
    _maxPickFileCount = maxPickFileCount;
    imagePicker.getImage(context);
  }
}

abstract class MediaPickerListener {
  void pickedFiles(List<Media?>? _pickedFilesList, PickFileType pickFileType);
}

enum PickFileType { image, video }

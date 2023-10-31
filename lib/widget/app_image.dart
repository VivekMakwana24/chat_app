import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gotms_chat/values/colors.dart';
import 'package:gotms_chat/values/export.dart';

class AppImage extends StatefulWidget {
  String? url;
  String? file;
  String? assets;
  String? initial;
  late double radius;
  Color? backgroundColor;
  late Color borderColor;
  late double boarderWidth;
  TextStyle? textStyle;
  double? height;
  double? width;
  double? roundedCorner;
  Widget? placeHolder;
  BoxFit? boxFit;

  AppImage(
      {this.url,
      this.boxFit,
      this.file,
      this.height,
      this.width,
      this.assets,
      this.initial,
      this.radius = 1,
      this.placeHolder,
      this.roundedCorner,
      this.backgroundColor,
      this.borderColor = Colors.transparent,
      this.boarderWidth = 3.0,
      this.textStyle});

  @override
  _AppImageState createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  @override
  Widget build(BuildContext context) {
    if (widget.textStyle == null) widget.textStyle = textMedium;
    if (widget.url != null) if (widget.url!.isEmpty) widget.url = null;

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      // for rounded corner
      child: widget.url != null
          ? CachedNetworkImage(
              //cacheKey: Uri.parse(widget.url).pathSegments.last,
              imageUrl: widget.url!,
              height: widget.height ?? widget.radius * 2,
              width: widget.width ?? widget.radius * 2,
              fit: widget.boxFit ?? BoxFit.cover,
              placeholder: (context, url) => placeholder,
              errorWidget: (context, url, error) => initialPlaceholder,
            )
          : widget.file != null
              ? Image(
                  image: FileImage(File(widget.file!)),
                  fit: BoxFit.cover,
                  height: widget.radius * 2,
                  width: widget.radius * 2,
                )
              : widget.assets != null
                  ? Image.asset(
                      widget.assets!,
                      fit: BoxFit.scaleDown,
                      height: widget.height ?? widget.radius * 2,
                      width: widget.width ?? widget.radius * 2,
                    )
                  : initialPlaceholder,
    );
  }

  get placeholder => widget.placeHolder != null
      ? widget.placeHolder
      : widget.initial != null
          ? initialPlaceholder
          : AspectRatio(
              aspectRatio: 1.5,
              child: Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.toolbarColor),
                ),
              ),
            );

  get initialPlaceholder => Container(
      height: widget.radius * 2,
      width: widget.radius * 2,
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          border: Border.all(
              width: widget.boarderWidth, color: widget.borderColor, style: BorderStyle.solid)),
      child: Center(child: Text(getText, style: widget.textStyle)));

  String get getText {
    if (widget.initial == null) {
      return "";
    } else if (widget.initial!.isEmpty) {
      return "";
    } else {
      return widget.initial![0];
    }
  }
}

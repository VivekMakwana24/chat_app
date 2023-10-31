import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotms_chat/generated/assets.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:gotms_chat/values/extensions/context_ext.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class TextTypingBox extends StatefulWidget {
  const TextTypingBox({super.key});

  @override
  State<TextTypingBox> createState() => _TextTypingBoxState();
}

class _TextTypingBoxState extends State<TextTypingBox> {
  //IMAGE

  void showModal() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: 160,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Column(
              children: [
                //CAMERA
                InkWell(
                  onTap: () {
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "",
                        height: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Use camera",
                        style: GoogleFonts.openSans(
                          fontSize: context.height * .022,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                //GALERY
                const SizedBox(height: 16),
                const Divider(
                  thickness: .8,
                  color: Colors.black12,
                ),
                const SizedBox(height: 16),
                //GALERY
                InkWell(
                  onTap: () {
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "",
                        height: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Upload from gallery",
                        style: GoogleFonts.openSans(
                          fontSize: context.height * .022,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  File? image;

  @override
  Widget build(BuildContext context) {
    return //TYPING TEXT
        Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 14, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //TEXT MESSAGE TYPING
            Expanded(
              child: TextField(
                cursorColor: ColorData.primary,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(right: 40),
                  border: InputBorder.none,
                  hintText: "Message",
                  hintStyle: GoogleFonts.openSans(
                    color: ColorData.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: GoogleFonts.openSans(
                  color: ColorData.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //GALLERY BTN
            InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                // return showModal();
              },
              child: SvgPicture.asset(
                Assets.svgsGallery,
              ),
            ),
            20.widthBox,

            //SEND BUTTON
            InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
              },
              child: SvgPicture.asset(
                Assets.svgsSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

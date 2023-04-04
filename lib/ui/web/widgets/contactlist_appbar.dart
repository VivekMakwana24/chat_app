import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class ContactlistAppBar extends StatelessWidget {
  const ContactlistAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorData.lightGrey),
        ),
        color: ColorData.white,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              "Message",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ColorData.black,
              ),
            ),
          ),
          20.widthBox,
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: ColorData.primary,
            ),
            child: Text(
              "01",
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorData.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

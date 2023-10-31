import 'package:flutter/material.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class ContactlistAppBar extends StatelessWidget {
  const ContactlistAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
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
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorData.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

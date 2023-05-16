import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:google_fonts/google_fonts.dart';

class SenderChatBubble extends StatelessWidget {
  final String message;

  const SenderChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (Alignment.topLeft),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            10,
          ),
          color: (ColorData.lightGrey.withOpacity(.5)),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: (ColorData.black),
          ),
        ),
      ),
    );
  }
}

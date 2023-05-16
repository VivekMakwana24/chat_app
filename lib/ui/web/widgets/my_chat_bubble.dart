import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:google_fonts/google_fonts.dart';

class MyChatBubble extends StatelessWidget {
  final String message;

  const MyChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (Alignment.topRight),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            10,
          ),
          color: (ColorData.primary),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: (ColorData.white),
          ),
        ),
      ),
    );
  }
}

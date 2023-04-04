import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

//SEARCH BAR
class SearchBar extends StatelessWidget {
  final String hintText;

  const SearchBar({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorData.grey200.withOpacity(.4),
      ),
      child: TextFormField(
        cursorColor: ColorData.black,
        cursorHeight: (context.height) * .021,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          counterText: '',
          border: const OutlineInputBorder(),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: SvgPicture.asset(
              Assets.svgsSearch,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          hintText: hintText,
          labelStyle: GoogleFonts.nunito(
            color: ColorData.black,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: GoogleFonts.nunito(
            color: ColorData.black,
            fontSize: 16,
          ),
        ),
        style: GoogleFonts.nunito(
          color: ColorData.black,
          fontSize: 16,
        ),
      ),
    );
  }
}

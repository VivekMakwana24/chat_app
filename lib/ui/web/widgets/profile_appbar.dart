import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class WebProfileAppbar extends StatefulWidget {
  const WebProfileAppbar({super.key});

  @override
  State<WebProfileAppbar> createState() => _WebProfileAppbarState();
}

class _WebProfileAppbarState extends State<WebProfileAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorData.lightGrey),
        ),
        color: ColorData.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Row(
          children: [
            //IMAGE
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    "https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg"),
              ),
            ),

            //NAME & MSG
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "User Name",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorData.black,
                  ),
                ),
                03.heightBox,
                Text(
                  "Online",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorData.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

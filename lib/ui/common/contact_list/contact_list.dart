import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/model/info.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/export.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: info.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          child: ListTile(
            //IMAGE
            leading: CircleAvatar(
              radius: (context.height) * .04,
              backgroundImage: NetworkImage(
                info[index]['profilePic'].toString(),
              ),
            ),

            //NAME
            title: Text(
              info[index]['name'].toString(),
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorData.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),

            //MESSAGE
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                info[index]['message'].toString(),
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorData.grey,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            //TIME
            trailing: Text(
              info[index]['time'].toString(),
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: ColorData.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

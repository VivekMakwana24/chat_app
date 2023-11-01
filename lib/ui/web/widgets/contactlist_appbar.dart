import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gotms_chat/ui/home/new_group/new_group_page.dart';
import 'package:gotms_chat/ui/home/user_list_page.dart';
import 'package:gotms_chat/ui/web/widgets/left_navbar.dart';
import 'package:gotms_chat/values/colors.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:gotms_chat/values/extensions/widget_ext.dart';
import 'package:gotms_chat/widget/button_widget.dart';

class ContactlistAppBar extends StatelessWidget {
  final SelectedScreen selectedScreen;

  const ContactlistAppBar({
    this.selectedScreen = SelectedScreen.RecentChat,
    super.key,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              selectedScreen == SelectedScreen.RecentChat ? "Message" : "Groups",
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorData.black,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(right: 10),
              width: 100,
              child: AppButton(
                'Create Group',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserListPage(
                        isForGroup: true,
                        pageType: PageType.NEW_GROUP,
                      ),
                    ),
                  );
                },
                height: 30,
                radius: 6,
                color: AppColor.primaryColor,
                buttonColor: true,
              ),
            ),
          ).visiblity(
            selectedScreen == SelectedScreen.Groups,
          ),
        ],
      ),
    );
  }
}

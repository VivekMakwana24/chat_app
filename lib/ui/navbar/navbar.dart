import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotms_chat/generated/assets.dart';
import 'package:gotms_chat/ui/home/new_group/new_group_page.dart';
import 'package:gotms_chat/ui/home/user_list_page.dart';
import 'package:gotms_chat/ui/mobile/chat_screen/chat_screen.dart';
import 'package:gotms_chat/ui/mobile/message_page_mobile.dart';
import 'package:gotms_chat/values/colors.dart';
import 'package:gotms_chat/values/colors_new.dart';
import 'package:gotms_chat/values/extensions/context_ext.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int currentTab = 1;
  final List<Widget> screens = [
    const MessagePageMobile(),
    UserListPage(isForGroup: false, pageType: PageType.USERS),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const MessagePageMobile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 6,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              //MESSAGE
              const Spacer(flex: 1),
              MaterialButton(
                onPressed: () {
                  setState(
                    () {
                      currentScreen = screens.first;
                      currentTab = 1;
                      HapticFeedback.heavyImpact();
                    },
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    SvgPicture.asset(
                      Assets.svgsMessage,
                      color: currentTab == 1 ? ColorData.primary : ColorData.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Message",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: context.height * .016,
                        color: currentTab == 1 ? ColorData.primary : ColorData.grey,
                      ),
                    ),
                  ],
                ),
              ),

              //SPACER
              const Spacer(flex: 10),

              //GROUP
              MaterialButton(
                onPressed: () {
                  setState(
                    () {
                      currentScreen = screens.last;
                      currentTab = 2;
                      HapticFeedback.heavyImpact();
                    },
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    SvgPicture.asset(
                      Assets.svgsGroups,
                      color: currentTab == 2 ? ColorData.primary : ColorData.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Group",
                      style: GoogleFonts.openSans(
                        fontSize: context.height * .016,
                        fontWeight: FontWeight.w700,
                        color: currentTab == 2 ? ColorData.primary : ColorData.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
      // floatingActionButton: buildFab(context),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: ColorData.primary,
          child: SvgPicture.asset(
            Assets.svgsLogo,
            height: 24,
          ),
          onPressed: () {
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  ExpandableFab buildFab(BuildContext context) {
    return ExpandableFab(
      overlayStyle: ExpandableFabOverlayStyle(
        blur: 5,
      ),
      foregroundColor: AppColor.white,
      backgroundColor: AppColor.primaryColor,
      closeButtonStyle: ExpandableFabCloseButtonStyle(
        foregroundColor: AppColor.white,
        backgroundColor: AppColor.primaryColor,
      ),
      children: [
        FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.group_add),
          onPressed: () {

          },
          foregroundColor: AppColor.white,
          backgroundColor: AppColor.primaryColor,
        ),
        FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.supervised_user_circle),
          foregroundColor: AppColor.white,
          backgroundColor: AppColor.primaryColor,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserListPage(
                    isForGroup: false,
                    pageType: PageType.USERS,
                  ),
                ));
          },
        ),
      ],
    );
  }
}

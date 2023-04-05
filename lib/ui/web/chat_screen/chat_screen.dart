import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/ui/home/home_page.dart';
import 'package:flutter_demo_structure/ui/home/new_group/new_group_page.dart';
import 'package:flutter_demo_structure/ui/home/user_list_page.dart';
import 'package:flutter_demo_structure/ui/web/widgets/left_navbar.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';

class WebChatScreen extends StatefulWidget {
  const WebChatScreen({super.key});

  @override
  State<WebChatScreen> createState() => _WebChatScreenState();
}

class _WebChatScreenState extends State<WebChatScreen> {
  SelectedScreen selectedScreen = SelectedScreen.OneToOne;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorData.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //LEFT NAV BAR
          LeftNavBar(
            selectedScreen: selectedScreen,
            onScreenChange: (screen) {
              selectedScreen = screen;
              setState(() {

              });
            },
          ),
          //DEVIDER
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: ColorData.lightGrey),
                bottom: BorderSide(color: ColorData.lightGrey),
              ),
              color: ColorData.white,
            ),
          ),

          //WEB PROFILE
          Expanded(
            child: selectedScreen == SelectedScreen.OneToOne
                ? HomePage()
                : UserListPage(
                    isForGroup: false,
                    pageType: PageType.USERS,
                  ),
          ),

          /* //DEVIDER
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: ColorData.lightGrey),
                bottom: BorderSide(color: ColorData.lightGrey),
              ),
              color: ColorData.white,
            ),
          ),*/

          /*//WEB MESSAGE  SCREEN
          const Expanded(
            flex: 2,
            child: MessageScreen(),
          ),*/
        ],
      ),
    );
  }
}

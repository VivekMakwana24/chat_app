import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/ui/common/contact_list/contact_list.dart';
import 'package:flutter_demo_structure/ui/home/home_page.dart';
import 'package:flutter_demo_structure/ui/web/widgets/contactlist_appbar.dart';
import 'package:flutter_demo_structure/ui/web/widgets/left_navbar.dart';
import 'package:flutter_demo_structure/ui/web/widgets/message_screen.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/widget/search_bar.dart';

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
            selectedScreen: SelectedScreen.OneToOne,
            onScreenChange: (screen) {},
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
            child: HomePage(),
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

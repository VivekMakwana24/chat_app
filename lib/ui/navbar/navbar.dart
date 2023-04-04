import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/ui/mobile/chat_screen/chat_screen.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_demo_structure/values/extensions/context_ext.dart';
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
    const MobileChatScreen(),
    const Placeholder(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const MobileChatScreen();

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
                      currentScreen = const Placeholder();
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
                      style: GoogleFonts.nunito(
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
                      currentScreen = const MobileChatScreen();
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
                      style: GoogleFonts.nunito(
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
            HapticFeedback.heavyImpact();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

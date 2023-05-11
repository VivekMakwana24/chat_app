import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/main.dart';
import 'package:flutter_demo_structure/ui/auth/login/login_page.dart';
import 'package:flutter_demo_structure/values/colors_new.dart';
import 'package:flutter_svg/svg.dart';
import 'package:velocity_x/velocity_x.dart';

enum SelectedScreen { OneToOne, Groups }

class LeftNavBar extends StatefulWidget {
  SelectedScreen selectedScreen;
  final Function(SelectedScreen) onScreenChange;

  LeftNavBar({
    required this.selectedScreen,
    required this.onScreenChange,
    super.key,
  });

  @override
  State<LeftNavBar> createState() => _LeftNavBarState();
}

class _LeftNavBarState extends State<LeftNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 80,
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          //LOGO
          SvgPicture.asset(
            Assets.svgsLogo,
            height: 40,
          ),
          50.heightBox,

          //ICONS
          Column(
            children: [
              //CHAT ICON
              InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  if (widget.selectedScreen == SelectedScreen.OneToOne) return;
                  widget.selectedScreen = SelectedScreen.OneToOne;
                  widget.onScreenChange(widget.selectedScreen);
                  setState(() {});
                },
                child: SvgPicture.asset(
                  color: widget.selectedScreen == SelectedScreen.OneToOne ? ColorData.primary : ColorData.lightGrey,
                  Assets.svgsMessage,
                  height: 30,
                ),
              ),
              40.heightBox,

              //GROUP ICON
              InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  if (widget.selectedScreen == SelectedScreen.Groups) return;

                  widget.selectedScreen = SelectedScreen.Groups;
                  widget.onScreenChange(widget.selectedScreen);
                  setState(() {});
                },
                child: SvgPicture.asset(
                  color: widget.selectedScreen == SelectedScreen.Groups ? ColorData.primary : ColorData.lightGrey,
                  Assets.svgsGroups,
                  height: 30,
                ),
              ),
            ],
          ),

          //SPACCER

          const Spacer(),

          //LOGOUT ICON
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              firebaseChatManager.logoutUser();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (route) => false);
            },
            child: SvgPicture.asset(
              Assets.svgsLogout,
              height: 30,
            ),
          ),
          30.heightBox,
        ],
      ),
    );
  }
}

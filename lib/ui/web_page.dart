import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/ui/navbar/navbar.dart';
import 'package:flutter_demo_structure/ui/web/chat_screen/chat_screen.dart';
import 'package:flutter_demo_structure/widget/responsive_layout.dart';

class WebPage extends StatefulWidget {
  final String? queryParam;

  const WebPage({this.queryParam, super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {

  @override
  void initState() {
    super.initState();

    debugPrint('WEP PAGE CALLED ==> ${widget.queryParam}');
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      queryParam: widget.queryParam,
      webScreenLayout: WebChatScreen(),
      tabletScreenLayout: MyBottomNavigationBar(),
      mobileScreenLayout: MyBottomNavigationBar(),
    );
  }
}

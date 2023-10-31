import 'package:flutter/material.dart';
import 'package:gotms_chat/ui/common/contact_list/contact_list.dart';
import 'package:gotms_chat/widget/base_app_bar.dart';
import 'package:gotms_chat/widget/search_bar.dart';

class MobileChatScreen extends StatefulWidget {
  const MobileChatScreen({super.key});

  @override
  State<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends State<MobileChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(leadingIcon: true, title: "Messages"),
      body: Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(20),
            child: SearchBarCustom(hintText: "Search..."),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4, right: 4),
              child: ContactList(),
            ),
          ),
        ],
      ),
    );
  }
}

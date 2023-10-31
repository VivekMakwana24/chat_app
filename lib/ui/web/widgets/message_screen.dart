import 'package:flutter/material.dart';
import 'package:gotms_chat/ui/web/widgets/chat_list.dart';
import 'package:gotms_chat/ui/web/widgets/profile_appbar.dart';
import 'package:gotms_chat/ui/web/widgets/typing_textbox.dart';
import 'package:gotms_chat/values/colors_new.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //APP BAR
        const WebProfileAppbar(),
        // 20.heightBox,

        //CHAT LIST
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ChatList(),
          ),
        ),

        //INPUT FIELD
        Container(
          height: 70,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: ColorData.lightGrey),
            ),
            color: ColorData.white,
          ),
          width: MediaQuery.of(context).size.width * 0.65,
          child: const TextTypingBox(),
        ),
      ],
    );
  }
}

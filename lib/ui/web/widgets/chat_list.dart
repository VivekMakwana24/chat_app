import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/model/info.dart';
import 'package:flutter_demo_structure/ui/web/widgets/my_chat_bubble.dart';
import 'package:flutter_demo_structure/ui/web/widgets/sender_chat_bubble.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        if (messages[index]['isMe'] == true) {
          //MY MESSAGE CARD
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyChatBubble(
              message: messages[index]['text'].toString(),
            ),
          );
        }
        //SENDER MESSAGE CARD
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SenderChatBubble(
            message: messages[index]['text'].toString(),
          ),
        );
      },
    );
  }
}

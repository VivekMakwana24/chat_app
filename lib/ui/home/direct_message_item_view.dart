import 'package:flutter/material.dart';
import 'package:gotms_chat/ui/home/text_message_item_view.dart';
import 'package:gotms_chat/util/firebase_chat_manager/models/chat_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DirectMessageItemView extends StatefulWidget {
  final ChatMessage message;
  final List<int>? notFoundList;

  const DirectMessageItemView({
    required this.message,
    this.notFoundList,
  });

  @override
  State<DirectMessageItemView> createState() => _DirectMessageItemViewState();
}

class _DirectMessageItemViewState extends State<DirectMessageItemView> {
  /*
    * *****************************************************
    * Class Members
    * *****************************************************
    * */

  // region Class Members

  ChatMessage get message => widget.message;

  // endregion

  /*
    * *****************************************************
    * Lifecycle functions
    * *****************************************************
    * */

  // region Lifecycle functions
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // endregion

  /*
   * *****************************************************
   * UI functions
   * *****************************************************
   * */

  // region UI functions

  // endregion

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!message.isLeftSide) ...[
            SizedBox(
              width: 70.w,
            ),
          ],
          _buildContent(),
          if (message.isLeftSide) ...[
            SizedBox(
              width: 70.w,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (message.type) {
      case SendMessageType.text:
        return TextMessageItemView(message: message);

      default:
        return Container();
    }
  }

/*
   * *****************************************************
   * Observers and Api
   * *****************************************************
   */

// region Observers and Api

// endregion

}

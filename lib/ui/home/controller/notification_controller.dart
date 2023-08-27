import 'package:flutter_demo_structure/util/firebase_chat_manager/models/chat_message.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final RxList<ChatMessage> _getNotificationList = <ChatMessage>[].obs;

  List<ChatMessage>? get getNotificationList => _getNotificationList.value;

  void setNotificationData(ChatMessage notificationData) {
    _getNotificationList.add(notificationData);
  }
}

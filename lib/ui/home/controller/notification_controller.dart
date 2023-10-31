import 'package:gotms_chat/util/firebase_chat_manager/models/chat_message.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final RxList<ChatMessage> _getNotificationList = <ChatMessage>[].obs;

  List<ChatMessage>? get getNotificationList => _getNotificationList.value;

  RxInt notificationCount = 0.obs;

  Rx<ChatMessage>? selectedItem = ChatMessage().obs;

  void setNotificationData(ChatMessage notificationData) {
    _getNotificationList.insert(0, notificationData);
  }
}

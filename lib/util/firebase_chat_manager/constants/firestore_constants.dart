import 'package:gotms_chat/core/db/app_db.dart';

class FirestoreConstants {
  static const user_name = "user_name";
  static const aboutMe = "aboutMe";
  static const photoUrl = "photoUrl";
  static const id = "id";
  static const userId = "user_id";
  static const chattingWith = "chatting_with";
  static const idFrom = "idFrom";
  static const idTo = "idTo";
  static const timestamp = "timestamp";
  static const createdAt = "created_at";
  static const content = "content";
  static const type = "type";

  static const chatId = "chat_id";
  static const openChatsIds = 'open_chats_ids';
  static const participants = 'participants';
  static const participantsNotification = 'participants_notification';
  static const usernamesIsTyping = 'usernames_is_typing';
  static const unreadCountList = 'unread_count_list';
  static const receiver_name = 'receiver_name';
  static const group_name = 'group_name';
  static const isGroup = 'is_group';

  static getUnreadCountKey(String? userId) {
    return userId.toString() + '_unreadCount';
  }

  static String getChatId(String? receiver) {
    if (appDB.currentUserId.compareTo(receiver ?? '')>0) {
      return (appDB.currentUserId.toString() ?? '') + '_' + receiver.toString();
    } else {
      return receiver.toString() + '_' + (appDB.currentUserId.toString() ?? '');
    }
  }
}

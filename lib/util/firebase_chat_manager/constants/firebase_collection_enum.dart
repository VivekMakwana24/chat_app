enum FirebaseCollection { users, recent_chat, chat }

enum MessageType { text, image, sticker }

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return "0";

      case MessageType.image:
        return "1";

      case MessageType.sticker:
        return "2";
    }
  }
}

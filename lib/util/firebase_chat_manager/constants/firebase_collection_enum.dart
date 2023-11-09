import 'package:gotms_chat/core/di/api/api_end_points.dart';

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

extension FirebaseCollectionExtension on FirebaseCollection {
  String get value {
    String environment = '';

    if (APIEndPoints.environment == ApplicationEnvironment.staging ||
        APIEndPoints.environment == ApplicationEnvironment.development) {
      environment = 'stg_';
    }

    switch (this) {
      case FirebaseCollection.users:
        return environment + FirebaseCollection.users.name;

      case FirebaseCollection.recent_chat:
        return environment + FirebaseCollection.recent_chat.name;

      case FirebaseCollection.chat:
        return environment + FirebaseCollection.chat.name;
    }
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:gotms_chat/core/db/app_db.dart';
import 'package:gotms_chat/util/date_time_enum.dart';
import 'package:gotms_chat/util/date_time_helper.dart';
import 'package:gotms_chat/util/firebase_chat_manager/constants/firestore_constants.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:velocity_x/velocity_x.dart';

part 'chat_message.g.dart';

enum SendMessageType { text, image }

extension SendMessageTypeExtension on SendMessageType {
  String get typeValue {
    switch (this) {
      case SendMessageType.text:
        return 'text';

      case SendMessageType.image:
        return 'image';
    }
  }
}

@JsonSerializable(explicitToJson: true, ignoreUnannotated: true)
class ChatMessage {
  @JsonKey(name: 'chat_id')
  String? chatId;
  @JsonKey(name: 'sender_id')
  String? senderId;

  @JsonKey(name: 'receiver_id')
  String? receiverId;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'media_path')
  String? mediaPath;

  @JsonKey(name: 'type')
  String? messageType;

  @JsonKey(name: 'created_at')
  String? createdAt;

  @JsonKey(name: 'receiver_name')
  String? receiverName;

  @JsonKey(name: 'sender_name')
  String? senderName;

  @JsonKey(name: 'receiver_profile')
  String? receiverProfile;

  @JsonKey(name: 'sender_profile')
  String? senderProfile;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'body')
  String? body;

  @JsonKey(name: 'is_admin')
  bool? isAdmin;

  @JsonKey(name: 'system_generated')
  bool? systemGenerated;

  @JsonKey(name: FirestoreConstants.participants)
  List<String?>? participants;

  @JsonKey(name: FirestoreConstants.openChatsIds)
  List<String?>? openChatIds;

  @JsonKey(name: FirestoreConstants.usernamesIsTyping)
  List<String?>? usernamesIsTyping;

  @JsonKey(name: FirestoreConstants.unreadCountList)
  Map<String, dynamic>? unreadCountList;

  @JsonKey(name: 'post_type')
  String? postTypeString;

  @JsonKey(name: 'group_name')
  String? groupName;

  @JsonKey(name: 'is_group', defaultValue: false)
  bool? isGroup;

  int get unreadCount => (unreadCountList?[FirestoreConstants.getUnreadCountKey(appDB.user?.userId)] ?? 0);

  bool isFailed;
  bool isFromComment;
  bool isSelected = false;
  bool isPlaying = false;
  bool isLoading = false;

  bool get isLeftSide => appDB.user?.userId != senderId;

  SendMessageType get type => SendMessageType.values.byName(messageType?.lowerCamelCase ?? '');

  String? get getChatName {
    if (appDB.user?.userId == senderId) {
      return receiverName;
    } else {
      return senderName;
    }
  }

  String? get getOtherUserId {
    if (appDB.user?.userId == senderId) {
      return receiverId;
    } else {
      return senderId;
    }
  }

  String? get getName {
    debugPrint('=> ${appDB.user?.userId}');
    debugPrint('=> $senderId');
    debugPrint('=> $receiverName');
    debugPrint('=> $senderName');
    if (appDB.user?.userId == senderId) {
      return receiverName;
    } else {
      return senderName;
    }
  }

  String get getChatIcon {
    if (appDB.user?.userId == senderId) {
      return receiverProfile ?? '';
    } else {
      return senderProfile ?? '';
    }
  }

  String get getGroupSenderName {
    if (appDB.user?.userId == senderId) {
      return 'You';
    } else {
      return senderName ?? '';
    }
  }

  DateTime get insertDateInLocal => (createdAt?.isEmptyOrNull ?? false)
      ? DateTime.now()
      : (createdAt ?? '').formatDateTimeToLocalDate() ??
          DateTime.fromMillisecondsSinceEpoch(
            int.parse(createdAt ?? '0'),
          );

  String get dateString {
    if (insertDateInLocal.isToday()) {
      return 'Today';
    } else if (insertDateInLocal.isYesterday()) {
      return 'Yesterday';
    }
    return DateFormat('MM/dd/yy').format(insertDateInLocal);
  }

  ChatMessage({
    this.chatId,
    this.senderId,
    this.receiverId,
    this.message,
    this.mediaPath,
    this.messageType,
    this.createdAt,
    this.isFailed = false,
    this.isFromComment = false,
    this.receiverProfile,
    this.receiverName,
    this.participants,
    this.openChatIds,
    this.usernamesIsTyping,
    this.senderName,
    this.senderProfile,
    this.unreadCountList,
    this.postTypeString,
    this.isAdmin,
    this.isGroup,
    this.groupName,
    this.title,
    this.body,
    this.systemGenerated = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  factory ChatMessage.toDocumentToClass(e) {
    return e.data() == null ? ChatMessage() : ChatMessage.fromJson(jsonDecode(jsonEncode(e.data())));
  }
}

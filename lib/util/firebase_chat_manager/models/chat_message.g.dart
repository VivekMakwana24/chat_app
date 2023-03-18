// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      chatId: json['chat_id'] as String?,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      message: json['message'] as String?,
      mediaPath: json['media_path'] as String?,
      messageType: json['type'] as String?,
      createdAt: json['created_at'] as String?,
      receiverProfile: json['receiver_profile'] as String?,
      receiverName: json['receiver_name'] as String?,
      participants: (json['participants'] as List<dynamic>?)?.map((e) => e as String?).toList(),
      openChatIds: (json['open_chats_ids'] as List<dynamic>?)?.map((e) => e as int?).toList(),
      usernamesIsTyping: (json['usernames_is_typing'] as List<dynamic>?)?.map((e) => e as String?).toList(),
      senderName: json['sender_name'] as String?,
      senderProfile: json['sender_profile'] as String?,
      unreadCountList: json['unread_count_list'] as Map<String, dynamic>?,
      postTypeString: json['post_type'] as String?,
      groupName: json['group_name'] as String?,
      isAdmin: json['is_admin'] as bool?,
      isGroup: json['is_group'] as bool?,
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) => <String, dynamic>{
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'message': instance.message,
      'media_path': instance.mediaPath,
      'type': instance.messageType,
      'created_at': instance.createdAt,
      'receiver_name': instance.receiverName,
      'sender_name': instance.senderName,
      'receiver_profile': instance.receiverProfile,
      'sender_profile': instance.senderProfile,
      'is_admin': instance.isAdmin,
      'participants': instance.participants,
      'open_chats_ids': instance.openChatIds,
      'usernames_is_typing': instance.usernamesIsTyping,
      'unread_count_list': instance.unreadCountList,
      'post_type': instance.postTypeString,
      'is_group': instance.isGroup,
      'group_name': instance.groupName,
    };

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'firebase_chat_user.g.dart';

@HiveType(typeId: 1)
class FirebaseChatUser {
  FirebaseChatUser({
    this.deviceToken,
    this.deviceType,
    this.isOnline,
    this.userName,
    this.userImage,
    this.userEmail,
    this.createdAt,
    this.userId,
    this.password,
  });

  FirebaseChatUser.fromJson(dynamic json) {
    deviceToken = json['device_token'];
    deviceType = json['device_type'];
    isOnline = json['is_online'];
    userName = json['user_name'];
    userImage = json['user_image'];
    userEmail = json['user_email'];
    userId = json['id'];
    chattingWith = json['chatting_with'];
    createdAt = json['createdAt'];
  }

  @HiveField(0)
  String? userId;
  @HiveField(1)
  String? deviceToken;
  @HiveField(2)
  String? deviceType;
  @HiveField(3)
  bool? isOnline;
  @HiveField(5)
  String? userName;
  @HiveField(6)
  String? userImage;
  @HiveField(7)
  String? userEmail;
  @HiveField(8)
  String? chattingWith;
  @HiveField(9)
  String? createdAt;
  String? password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['device_token'] = deviceToken;
    map['device_type'] = deviceType;
    map['is_online'] = isOnline;
    map['user_id'] = userId;
    map['user_name'] = userName;
    map['user_image'] = userImage;
    map['user_email'] = userEmail;
    map['id'] = userId;
    map['chatting_with'] = chattingWith;
    map['createdAt'] = createdAt;
    map['password'] = password;
    return map;
  }

  factory FirebaseChatUser.fromDocument(DocumentSnapshot doc) {
    String id = "";
    String deviceToken = "";
    String userImage = "";
    String userEmail = "";
    String userName = "";
    String createdAt = "";
    int userId = 1;
    try {
      deviceToken = doc.get('device_token');
    } catch (e) {}
    try {
      userImage = doc.get('user_image');
    } catch (e) {}
    try {
      userEmail = doc.get('user_email');
    } catch (e) {}
    try {
      userName = doc.get('user_name');
    } catch (e) {}
    try {
      createdAt = doc.get('createdAt');
    } catch (e) {}
    try {
      userId = doc.get('user_id');
    } catch (e) {}
    return FirebaseChatUser(
      userId: doc.id,
      deviceToken: deviceToken,
      userEmail: userEmail,
      userName: userName,
      createdAt: createdAt,
    );
  }

}

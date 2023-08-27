// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_chat_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirebaseChatUserAdapter extends TypeAdapter<FirebaseChatUser> {
  @override
  final int typeId = 1;

  @override
  FirebaseChatUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FirebaseChatUser(
      deviceToken: fields[1] as String?,
      deviceType: fields[2] as String?,
      isOnline: fields[3] as bool?,
      userName: fields[5] as String?,
      userImage: fields[6] as String?,
      userEmail: fields[7] as String?,
      createdAt: fields[9] as String?,
      userId: fields[0] as String?,
    )..chattingWith = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, FirebaseChatUser obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.deviceToken)
      ..writeByte(2)
      ..write(obj.deviceType)
      ..writeByte(3)
      ..write(obj.isOnline)
      ..writeByte(5)
      ..write(obj.userName)
      ..writeByte(6)
      ..write(obj.userImage)
      ..writeByte(7)
      ..write(obj.userEmail)
      ..writeByte(8)
      ..write(obj.chattingWith)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirebaseChatUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

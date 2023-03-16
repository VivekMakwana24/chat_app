// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      id: fields[0] as int?,
      mobileNumber: fields[1] as String?,
      signupWith: fields[2] as String?,
      name: fields[3] as String?,
      email: fields[4] as String?,
      token: fields[7] as String?,
      profileImage: fields[6] as String?,
      countryCode: fields[5] as String?,
      dob: fields[8] as String?,
      gender: fields[9] as String?,
      loginType: fields[10] as String?,
      firstName: fields[11] as String?,
      lastName: fields[12] as String?,
      referralCode: fields[13] as String?,
      coin: fields[14] as int?,
      hotwordTotal: fields[15] as int?,
      playTotal: fields[16] as int?,
      storyTotal: fields[17] as int?,
      joiningBonus: fields[18] as int?,
      referTotal: fields[19] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mobileNumber)
      ..writeByte(2)
      ..write(obj.signupWith)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.countryCode)
      ..writeByte(6)
      ..write(obj.profileImage)
      ..writeByte(7)
      ..write(obj.token)
      ..writeByte(8)
      ..write(obj.dob)
      ..writeByte(9)
      ..write(obj.gender)
      ..writeByte(10)
      ..write(obj.loginType)
      ..writeByte(11)
      ..write(obj.firstName)
      ..writeByte(12)
      ..write(obj.lastName)
      ..writeByte(13)
      ..write(obj.referralCode)
      ..writeByte(14)
      ..write(obj.coin)
      ..writeByte(15)
      ..write(obj.hotwordTotal)
      ..writeByte(16)
      ..write(obj.playTotal)
      ..writeByte(17)
      ..write(obj.storyTotal)
      ..writeByte(18)
      ..write(obj.joiningBonus)
      ..writeByte(19)
      ..write(obj.referTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      id: json['id'] as int?,
      mobileNumber: json['mobile_number'] as String?,
      signupWith: json['signup_with'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      token: json['token'] as String?,
      profileImage: json['profile_image'] as String?,
      countryCode: json['country_code'] as String?,
      dob: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      loginType: json['login_type'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      referralCode: json['referal_code'] as String?,
      coin: json['coin'] as int?,
      hotwordTotal: json['hotword_total'] as int?,
      playTotal: json['sample_app_play_total'] as int?,
      storyTotal: json['story_read'] as int?,
      joiningBonus: json['joining_bonus'] as int?,
      referTotal: json['refer_total'] as int?,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'id': instance.id,
      'mobile_number': instance.mobileNumber,
      'signup_with': instance.signupWith,
      'name': instance.name,
      'email': instance.email,
      'country_code': instance.countryCode,
      'profile_image': instance.profileImage,
      'token': instance.token,
      'date_of_birth': instance.dob,
      'gender': instance.gender,
      'login_type': instance.loginType,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'referal_code': instance.referralCode,
      'coin': instance.coin,
      'hotword_total': instance.hotwordTotal,
      'sample_app_play_total': instance.playTotal,
      'story_read': instance.storyTotal,
      'joining_bonus': instance.joiningBonus,
      'refer_total': instance.referTotal,
    };

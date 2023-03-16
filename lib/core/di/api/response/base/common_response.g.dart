// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonResponse<T> _$CommonResponseFromJson<T>(Map<String, dynamic> json) =>
    CommonResponse<T>(
      data: json['data'],
      message: json['message'],
      code: json['code'],
    );

Map<String, dynamic> _$CommonResponseToJson<T>(CommonResponse<T> instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

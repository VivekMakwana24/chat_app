import 'package:json_annotation/json_annotation.dart';

import 'base_response.dart';

part 'common_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CommonResponse<T> extends BaseResponse<T> {
  CommonResponse({data, message, code});
  factory CommonResponse.fromJson(Map<String, dynamic> json, {Function()? fromJson}) =>
      CommonResponse<T>().parseJson(json, fromJson);

  get data {
    return data as T;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'message': message,
        'code': code,
        'data': data,
      };
}

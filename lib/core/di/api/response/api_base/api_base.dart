import 'dart:convert';

import 'package:flutter/material.dart';
//https://stackoverflow.com/a/65469596

class BaseResponse {
  dynamic message;
  late String? code;

  BaseResponse({this.message, this.code});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(code: json["code"], message: json["message"]);
  }
}

class SingleResponse<T> extends BaseResponse {
  T? data;

  SingleResponse({
    required String message,
    required String code,
    this.data,
  }) : super(message: message, code: code);

  factory SingleResponse.fromJson(Map<String, dynamic> json,
      {Function(Map<String, dynamic>)? create}) {
    debugPrint("DataMap:---------");
    debugPrint("${jsonEncode(json)}");
    debugPrint("${jsonEncode(json["data"])}");
    return SingleResponse<T>(
        code: json["code"],
        message: json["message"],
        data: json["data"] != null
            ? create != null
                ? create(json["data"])
                : json["data"]
            : null);
  }
}

class ListResponse<T> extends BaseResponse {
  List<T>? data;

  ListResponse({
    required String message,
    required String code,
    this.data,
  }) : super(message: message, code: code);

  factory ListResponse.fromJson(Map<String, dynamic> json,
      {Function(Map<String, dynamic>)? create}) {
    List<T> data = [];
    if (create != null) {
      json['data']?.forEach((v) {
        data.add(create(v));
      });
    } else {
      json['data']?.forEach((v) {
        data.add(v);
      });
    }
    return ListResponse<T>(code: json["code"], message: json["message"], data: data);
  }
}

class ListPageResponse<T> extends BaseResponse {
  List<T>? data;
  int? pageToken;

  ListPageResponse({
    required String message,
    required String code,
    this.data,
    this.pageToken,
  }) : super(message: message, code: code);

  factory ListPageResponse.fromJson(Map<String, dynamic> json,
      {Function(Map<String, dynamic>)? create}) {
    List<T> data = [];
    int pageToken = -1;
    if (json['data'] != null) {
      pageToken = json['data']['page_token'];
      if (create != null) {
        json['data']['result']?.forEach((v) {
          data.add(create(v));
        });
      } else {
        json['data']['result']?.forEach((v) {
          data.add(v);
        });
      }
    }

    return ListPageResponse<T>(
        code: json["code"], message: json["message"], data: data, pageToken: pageToken);
  }
}

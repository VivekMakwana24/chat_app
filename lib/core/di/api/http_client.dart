import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:gotms_chat/core/di/api/api_end_points.dart';
import 'package:gotms_chat/core/di/api/interceptor/custom_interceptors.dart';
import 'package:gotms_chat/core/di/api/interceptor/internet_interceptor.dart';
import 'package:gotms_chat/core/navigation/navigation_service.dart';
import 'package:gotms_chat/core/navigation/routes.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'app_exceptions.dart';
import 'dio_util_error.dart';

class HttpClient {
  late Dio _client;
  Map<String, dynamic> headers = {};

  HttpClient() {
    _client = Dio()
      ..options = BaseOptions(
        baseUrl: APIEndPoints.baseUrl,
        /*     requestEncoder: (String request, RequestOptions options) =>
            utf8.encode(enc.encrypt(jsonEncode(options.data))),
        responseDecoder:
            (List<int> responseBytes, RequestOptions options, ResponseBody responseBody) =>
                jsonDecode(enc.decrypt(utf8.decode(responseBytes))),*/
      );
    _client.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
      ),
    );
    _client.interceptors.add(InternetInterceptors());
    _client.interceptors.add(CustomInterceptors());
  }

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await _client.get(url);
      responseJson = returnResponse(response);
    } on DioError catch (e) {
      debugPrint('Dio Error');
      DioErrorUtil.handleError(e);
    }
    return responseJson;
  }

  Future post(String url, {dynamic body}) async {
    var responseJson;
    try {
      final response = await _client.post<String>(
        url,
        data: body,
        options: buildCacheOptions(Duration(minutes: 10)),
      );
      responseJson = returnResponse(response);
    } on DioError catch (e) {
      DioErrorUtil.handleError(e);
    }
    return responseJson;
  }

  Future put(String url, {dynamic body}) async {
    var responseJson;
    try {
      final response = await _client.put(url, data: body);
      responseJson = returnResponse(response);
    } on DioError catch (e) {
      DioErrorUtil.handleError(e);
    }

    return responseJson;
  }

  Future delete(String url, {dynamic body}) async {
    var apiResponse;
    try {
      final response = await _client.delete(url);
      apiResponse = returnResponse(response);
    } on DioError catch (e) {
      DioErrorUtil.handleError(e);
    }
    return apiResponse;
  }

  dynamic returnResponse(Response response) {
    final mapData = jsonDecode((response.data));
    debugPrint("${mapData["code"]}");
    switch (mapData["code"]) {
      case "0":
      case "1":
      case "2":
      case "11":
        return mapData;
      /*     case "-1":
        appDB.logout();
        navigator.pushNamedAndRemoveUntil(RouteName.signupOptionPage);
        //throw UnauthorisedException(response.data.toString());
        return mapData;*/
      default:
        throw FetchDataException('${response.statusCode}');
    }
  }

  dynamic returnResponse2(Response response) {
    switch (response.statusCode) {
      case 200:
      case 302:
        var responseJson = response.data;
        debugPrint(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        navigator.pushNamedAndRemoveUntil(RouteName.loginPage);
        throw UnauthorisedException(response.data.toString());
      case 500:
      default:
        throw FetchDataException('${response.statusCode}');
    }
  }

  wrapRequest(body) {
    debugPrint("-----------REQUEST-------------");
    debugPrint(body);
    debugPrint("------------------------");
    debugPrint(jsonEncode(body));
    return jsonEncode(body);
  }
}

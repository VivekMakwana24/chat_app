import 'package:gotms_chat/core/di/api/api_end_points.dart';
import 'package:gotms_chat/core/di/api/http_client.dart';
import 'package:gotms_chat/core/di/api/response/api_base/api_base.dart';
import 'package:gotms_chat/model/user_profile_response.dart';

import '../../../locator.dart';

abstract class IUserAuthRepository {
  Future<SingleResponse> login(Map<String, dynamic> data);
}

class UserAuthRepository extends IUserAuthRepository {
  @override
  Future<SingleResponse> login(Map<String, dynamic> data) async {
    final client = locator<HttpClient>();
    final response = await client.post(APIEndPoints.login, body: data);
    final finalData = SingleResponse<UserData>.fromJson(response, create: UserData.fromJson);
    return finalData;
  }
}

final authRepo = locator<UserAuthRepository>();

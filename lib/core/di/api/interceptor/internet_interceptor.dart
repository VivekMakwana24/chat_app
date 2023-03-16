import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

class InternetInterceptors extends Interceptor {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return handler.reject(
        DioError(
          requestOptions: options,
          response: Response(
            data: null,
            statusCode: -9,
            statusMessage: 'No Internet Connection',
            requestOptions: options,
          ),
          type: DioErrorType.other,
        ),
      );
    }
    return handler.next(options);
  }
}

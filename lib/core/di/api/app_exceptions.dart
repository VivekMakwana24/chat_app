class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return _message;
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class RequestCanceledException extends AppException {
  RequestCanceledException([String? message]) : super(message, "Invalid Input: ");
}

class ServerSideException extends AppException {
  ServerSideException([String? message]) : super(message, "Invalid Input: ");
}

class ConnectionException extends AppException {
  ConnectionException([String? message]) : super(message, "Invalid Input: ");
}

class NoInternetException extends AppException {
  NoInternetException([String? message]) : super(message, "No Active Internet Connection");
}

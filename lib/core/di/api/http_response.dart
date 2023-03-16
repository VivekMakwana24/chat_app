class HttpResponse<T> {
  int? status = 12029; // unable to connect server
  String? message = "";
  T? data;

  HttpResponse({this.status, this.message, this.data});
}

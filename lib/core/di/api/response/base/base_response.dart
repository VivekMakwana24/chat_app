class BaseResponse<T> {
  late String message;
  late String code;
  var data;

  parseJson(Map<String, dynamic> json, fromJson) {
    this.message = json['message'];
    this.code = json['code'];
    var data = json['data'];
    if (data != null) {
      if (data is Map<String, dynamic> && data["code"] == "0") {
        String error = json['message'];
        this.message = error;
      } else if (data is Map<String, dynamic>) {
        this.data = fromJson(data);
      } else if (data is List) {
        this.data = List<T>.from(data.map((itemsJson) {
          return fromJson(itemsJson);
        }));
      }
    }
    return this;
  }

  get dataModel {
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (data is List) {
      data['data'] = this.data.map((v) => dataModel.toJson()).toList();
    } else if (data is Map<String, dynamic>) {
      this.data = dataModel.toJson();
    }
    return data;
  }

  void validate() {
    switch (code) {
      case "0":
        break;
      case "1":
        //throw UnauthorisedException(message);
        break;
      case "2":
        break;
    }
  }
}

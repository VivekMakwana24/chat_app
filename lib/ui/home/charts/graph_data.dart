class GraphData {
  String? lineName;
  List<GraphDataDetails> graphDataDetails;

  GraphData(this.lineName, this.graphDataDetails);
}

class GraphDataDetails {
  DateTime date;
  String? name;
  String? source;
  String? device;
  String? sensorId;
  String? type;
  double? value;

  GraphDataDetails(this.date, this.name, this.source, this.device, this.sensorId, this.type, this.value);
}

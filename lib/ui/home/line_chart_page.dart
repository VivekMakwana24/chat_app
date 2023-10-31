/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotms_chat/ui/home/charts/graph_data.dart';
import 'package:gotms_chat/ui/home/charts/tooltip_chart.dart';
import 'package:gotms_chat/util/date_time_helper.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:gotms_chat/widget/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartPage extends StatefulWidget {
  const LineChartPage({Key? key}) : super(key: key);

  @override
  State<LineChartPage> createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> with TickerProviderStateMixin {
  List<GraphData>? _allGraphDataList = [];
  List<GraphData>? _gasGraphDataList = [];
  List<GraphData>? _temperatureGraphDataList = [];

  bool isDetailViewVisible = false;
  int _currentSelectedType = 0;

  GraphData? _selectedItem;

  List<GraphDataDetails> _generateList(int type) {
    return List.generate(
      10,
      (index) => GraphDataDetails(
        DateTime(2022, 2, index + 1),
        type == 0 ? 'Gas $index' : 'Line $index',
        '0',
        '1',
        '0013A200419F78A5_27TEMP',
        index % 2 == 0 ? 'temp' : 'celsius',
        double.parse(Random().nextDouble().toStringAsFixed(2)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _gasGraphDataList?.add(GraphData('Gas 1', _generateList(0)));
    _gasGraphDataList?.add(GraphData('Gas 2', _generateList(0)));
    _gasGraphDataList?.add(GraphData('Gas 3', _generateList(0)));

    _temperatureGraphDataList?.add(GraphData('Line 1', _generateList(1)));
    _temperatureGraphDataList?.add(GraphData('Line 2', _generateList(1)));
    _temperatureGraphDataList?.add(GraphData('Line 3', _generateList(1)));

    _allGraphDataList = _gasGraphDataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          //Initialize the chart widget

          _chart1(),

          20.h.verticalSpace,
        ]),
      ),
    );
  }

  // Initializing the gradient variable for the series.
  Widget _chart1() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        gradient: LinearGradient(
          colors: [
            Color(0xff1f211f),
            Color(0xff5b6275),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          _buildChartTypeSelection(),
          Hero(
            tag: 'chart',
            child: SfCartesianChart(
              enableAxisAnimation: true,
              palette: [Color(0xffaa4cfc), Color(0xff27b6fc), Color(0x444af699)],
              primaryXAxis: CategoryAxis(
                autoScrollingMode: AutoScrollingMode.start,
                majorGridLines: MajorGridLines(width: 0),
                zoomPosition: 0.1,
                zoomFactor: 0.6,
                //Hide the axis line of x-axis
                axisLine: AxisLine(width: 0),
                labelAlignment: LabelAlignment.center,
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              primaryYAxis: NumericAxis(
                autoScrollingMode: AutoScrollingMode.start,
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                //Hide the gridlines of y-axis
                majorGridLines: MajorGridLines(width: 0),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelAlignment: LabelAlignment.end,
                axisLine: AxisLine(width: 0),
              ),
              zoomPanBehavior: ZoomPanBehavior(
                enableSelectionZooming: true,
                enablePinching: true,
                maximumZoomLevel: 0.09,
                enableDoubleTapZooming: true,
                zoomMode: ZoomMode.x,
              ),
              // Chart title
              borderWidth: 1,
              title: ChartTitle(
                text: 'Remote Meter',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Enable legend
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  data as GraphDataDetails;
                  return ChartTooltip(data).addGestureTap(() {
                    if (!isDetailViewVisible) {
                      HapticFeedback.mediumImpact();
                      debugPrint('data name ${data.name}');
                      _selectedItem = _allGraphDataList?.firstWhere((element) => element.graphDataDetails
                          .contains(element.graphDataDetails.firstWhere((element) => element.name == data.name)));
                      if (_selectedItem == null) return;
                      isDetailViewVisible = true;
                      Future.delayed(
                        Duration(milliseconds: 100),
                        () => setState(() {}),
                      );
                    }
                  });
                },
              ),
              series: isDetailViewVisible
                  ? List.generate(
                      1,
                      (index) => SplineSeries<GraphDataDetails, dynamic>(
                        dataSource: _selectedItem!.graphDataDetails,
                        xValueMapper: (GraphDataDetails sales, _) => sales.date.toString().formatDateTime(),
                        yValueMapper: (GraphDataDetails sales, _) => sales.value,
                        name: _selectedItem!.lineName,
                        width: 5,
                        splineType: SplineType.natural,
                        animationDuration: 1000,
                        markerSettings: const MarkerSettings(isVisible: true, width: 10, height: 10),
                        // Enable data label
                        // gradient: LinearGradient(colors: gradientColors),
                        dataLabelSettings: DataLabelSettings(isVisible: false),
                      ),
                    )
                  : List.generate(
                      _allGraphDataList?.length ?? 0,
                      (index) => SplineSeries<GraphDataDetails, dynamic>(
                        dataSource: _allGraphDataList?[index].graphDataDetails ?? [],
                        xValueMapper: (GraphDataDetails sales, _) => sales.date.toString().formatDateTime(),
                        yValueMapper: (GraphDataDetails sales, _) => sales.value,
                        name: _allGraphDataList?[index].lineName,
                        width: 5,
                        splineType: SplineType.natural,
                        animationDuration: 1000,
                        markerSettings: const MarkerSettings(isVisible: true, width: 10, height: 10),
                        // Enable data label
                        // gradient: LinearGradient(colors: gradientColors),
                        dataLabelSettings: DataLabelSettings(isVisible: false),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the chart type selection
  Widget _buildChartTypeSelection() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            SizedBox(
              width: 100,
              height: 30,
              child: AppButton(
                'Gas',
                () {
                  _currentSelectedType = 0;
                  _allGraphDataList = _gasGraphDataList;
                  setState(() {});
                },
                buttonColor: _currentSelectedType != 1 ? true : false,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 100,
              height: 30,
              child: AppButton(
                'Temperature',
                () {
                  _currentSelectedType = 1;
                  _allGraphDataList = _temperatureGraphDataList;
                  setState(() {});
                },
                buttonColor: _currentSelectedType != 0 ? true : false,
              ),
            ),
          ]),
          Icon(
            Icons.refresh,
            color: Colors.white,
          ).addGestureTap(() {
            if (isDetailViewVisible) {
              HapticFeedback.mediumImpact();
              isDetailViewVisible = false;
              _selectedItem = null;
              setState(() {});
            }
          })
        ],
      ),
    );
  }
}
*/

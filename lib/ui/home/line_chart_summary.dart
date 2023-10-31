/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gotms_chat/ui/home/charts/graph_data.dart';
import 'package:gotms_chat/ui/home/charts/tooltip_chart.dart';
import 'package:gotms_chat/ui/home/line_chart_page.dart';
import 'package:gotms_chat/util/date_time_helper.dart';
import 'package:gotms_chat/values/export.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartSummaryPage extends StatefulWidget {
  const LineChartSummaryPage({Key? key}) : super(key: key);

  @override
  State<LineChartSummaryPage> createState() => _LineChartSummaryPageState();
}

class _LineChartSummaryPageState extends State<LineChartSummaryPage> {
  List<GraphData>? _allGraphDataList = [];
  bool isDetailViewVisible = false;

  List<GraphDataDetails> _generateList(int type) {
    return List.generate(
      20,
      (index) => GraphDataDetails(
        DateTime(2022, 2, index + 1),
        type == 0 ? 'Gas $index' : 'Line $index',
        '0',
        '1',
        '0013A200419F78A5_27TEMP',
        'gas',
        double.parse(Random().nextDouble().toStringAsFixed(2)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _allGraphDataList?.add(GraphData('Gas 1', _generateList(0)));
    _allGraphDataList?.add(GraphData('Gas 2', _generateList(0)));
    _allGraphDataList?.add(GraphData('Gas 3', _generateList(0)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _chart1(),
          ],
        ),
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
      child: Hero(
        tag: 'chart',
        child: SfCartesianChart(
            enableAxisAnimation: true,
            primaryXAxis: CategoryAxis(
              autoScrollingMode: AutoScrollingMode.start,
              zoomPosition: 0.1,
              zoomFactor: 0.6,
              isVisible: false,
            ),
            primaryYAxis: NumericAxis(
              autoScrollingMode: AutoScrollingMode.start,
              isVisible: false,
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enableSelectionZooming: true,
              enablePinching: true,
              enableDoubleTapZooming: true,
              zoomMode: ZoomMode.x,
            ),
            // Chart title
            borderWidth: 1,
            title: ChartTitle(
              text: 'Remote Meter Summary',
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Enable legend
            legend: Legend(isVisible: false),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(
              enable: true,
              builder: (data, point, series, pointIndex, seriesIndex) {
                data as GraphDataDetails;
                return ChartTooltip(data).addGestureTap(() {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => LineChartPage(),
                      transitionDuration: Duration(seconds: 2),
                      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                    ),
                  );
                });
              },
            ),
            series: <ChartSeries<GraphDataDetails, dynamic>>[
              SplineAreaSeries<GraphDataDetails, dynamic>(
                dataSource: _allGraphDataList?[0].graphDataDetails ?? [],
                xValueMapper: (GraphDataDetails sales, _) => sales.date.toString().formatDateTime(),
                yValueMapper: (GraphDataDetails sales, _) => sales.value,
                name: _allGraphDataList?[0].lineName,
                splineType: SplineType.natural,
                animationDuration: 2000,
                markerSettings: const MarkerSettings(isVisible: true, width: 10, height: 10, color: Colors.black),
                // Enable data label
                gradient: LinearGradient(
                  colors: const <Color>[
                    Color.fromRGBO(255, 255, 255, 1.0),
                    Color.fromRGBO(269, 210, 255, 1),
                  ],
                  stops: const <double>[0.2, 0.9],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderColor: Color.fromRGBO(81, 236, 255, 0.5686274509803921),
                borderWidth: 6,
                borderDrawMode: BorderDrawMode.excludeBottom,
                dataLabelSettings: DataLabelSettings(isVisible: false),
              ),
              // Add more series.
            ]),
      ),
    );
  }
}
*/

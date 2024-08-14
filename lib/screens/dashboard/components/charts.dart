import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  final Map<String, Map<String, double>> taskStatistics;
  final int totalTasks;

  const Chart({
    Key? key,
    required this.taskStatistics,
    required this.totalTasks,
  }) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Row(
          children: <Widget>[
            const SizedBox(height: 18),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> sections = [];
    for (var i = 0; i < widget.taskStatistics.length; i++) {
      String key = String.fromCharCode('A'.codeUnitAt(0) + i); // Converts 0 to 'A', 1 to 'B', etc.
      double percentage = widget.taskStatistics[key]!['percentage']!;
      double count = widget.taskStatistics[key]!['count']!;

      sections.add(PieChartSectionData(
        color: getColorForClass(key), // You need to create this method to return the color based on the class.
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      ));
    }
    return sections;
  }

  Color getColorForClass(String className) {
    switch (className) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.red;
      case 'C':
        return Colors.blueAccent;
      case 'D':
        return Colors.amberAccent;
      case 'E':
        return Colors.cyanAccent;
      default:
        return Colors.grey; // Default color
    }
  }
}

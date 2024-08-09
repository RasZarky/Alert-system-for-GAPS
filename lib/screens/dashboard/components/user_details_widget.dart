import 'dart:math';

import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/screens/calender/calender_main.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/charts.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/user_details_mini_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:widget_loading/widget_loading.dart';

class UserDetailsWidget extends StatefulWidget {
  const UserDetailsWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<UserDetailsWidget> createState() => _UserDetailsWidgetState();
}

class _UserDetailsWidgetState extends State<UserDetailsWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final databaseReference = FirebaseFirestore.instance;
  bool loading = false;
  int totalTaskss = 0;

  Map<String, Map<String, double>> _taskStatistics = {
    'A': {'count': 0, 'percentage': 0.0},
    'B': {'count': 0, 'percentage': 0.0},
    'C': {'count': 0, 'percentage': 0.0},
    'D': {'count': 0, 'percentage': 0.0},
    'E': {'count': 0, 'percentage': 0.0},
  };

  Future<void> _calculateTaskStatistics() async {
    try {
      setState(() {
        loading = true;
      });
      QuerySnapshot snapshot = await _firestore.collection('tasks').get();
      Map<String, int> classCounts = {
        'A': 0,
        'B': 0,
        'C': 0,
        'D': 0,
        'E': 0,
      };
      int totalTasks = snapshot.docs.length;

      setState(() {
        totalTaskss = totalTasks;
      });

      snapshot.docs.forEach((doc) {
        String taskClass = doc['class'];
        if (classCounts.containsKey(taskClass)) {
          classCounts[taskClass] = classCounts[taskClass]! + 1;
        }
      });

      classCounts.forEach((key, value) {
        double percentage = totalTasks > 0 ? (value / totalTasks) * 100 : 0.0;
        _taskStatistics[key] = {'count': value.toDouble(), 'percentage': percentage};
      });

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error fetching tasks: $e");
    }
  }

  List<Color> _colorCollection = <Color>[];
  void _initializeEventColor() {
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));
  }

  @override
  void initState() {
    super.initState();
    _calculateTaskStatistics();
    _initializeEventColor();
  }

  @override
  Widget build(BuildContext context) {
    return CircularWidgetLoading(
      dotColor: Colors.green,
      loading: loading,
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: SingleChildScrollView( // Added SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remove the Expanded widget here
              Container(
                height: MediaQuery.of(context).size.height*0.8,
                child: StreamBuilder<QuerySnapshot>(
                  stream: databaseReference.collection("tasks").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final Random random = Random();
                    List<Meeting> list = snapshot.data!.docs.map((e) {
                      var data = e.data() as Map<String, dynamic>;
                      return Meeting(
                        eventName: "Class '${data['class']}' (${data["activity"]}).",
                        from: (data['startDate'] as Timestamp).toDate(),
                        to: (data['endDate'] as Timestamp).toDate(),
                        background: _colorCollection[random.nextInt(9)],
                        isAllDay: false,
                      );
                    }).toList();

                    return SfCalendar(
                      view: CalendarView.month,
                      initialDisplayDate: DateTime.now(),
                      showDatePickerButton: true,
                      showCurrentTimeIndicator: true,
                      showNavigationArrow: true,
                      showTodayButton: true,
                      allowViewNavigation: true,
                      dataSource: MeetingDataSource(list),
                      monthViewSettings: MonthViewSettings(
                        showAgenda: true,
                      ),
                    );
                  },
                ),
              ),
              Text(
                "Tasks Ratio",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: defaultPadding),
              Chart(
                taskStatistics: _taskStatistics,
                totalTasks: totalTaskss,
              ),
              UserDetailsMiniCard(
                color: Colors.green,
                title: "Class A",
                amountOfFiles: "${_taskStatistics['A']!['percentage']!.toStringAsFixed(1)}%",
                numberOfIncrease: _taskStatistics['A']!['count']!,
              ),
              UserDetailsMiniCard(
                color: Colors.red,
                title: "Class B",
                amountOfFiles: "${_taskStatistics['B']!['percentage']!.toStringAsFixed(1)}%",
                numberOfIncrease: _taskStatistics['B']!['count']!,
              ),
              UserDetailsMiniCard(
                color: Colors.blueAccent,
                title: "Class C",
                amountOfFiles: "${_taskStatistics['C']!['percentage']!.toStringAsFixed(1)}%",
                numberOfIncrease: _taskStatistics['C']!['count']!,
              ),
              UserDetailsMiniCard(
                color: Colors.amberAccent,
                title: "Class D",
                amountOfFiles: "${_taskStatistics['D']!['percentage']!.toStringAsFixed(1)}%",
                numberOfIncrease: _taskStatistics['D']!['count']!,
              ),
              UserDetailsMiniCard(
                color: Colors.cyanAccent,
                title: "Class E",
                amountOfFiles: "${_taskStatistics['E']!['percentage']!.toStringAsFixed(1)}%",
                numberOfIncrease: _taskStatistics['E']!['count']!,
              ),
            ],
          ),
        ),
      ),
    );
  }


}

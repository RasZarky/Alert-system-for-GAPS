library dashboard;

import 'dart:async';
import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/screens/calender/calenders.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/constans/app_constants.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/card_task.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/header_text.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/list_task_assigned.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/list_task_date.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/responsive_builder.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/simple_selection_button.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/simple_user_profile.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/shared_components/task_progress.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/utils/helpers/app_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';


// component
part '../components/header_weekly_task.dart';
part '../components/task_menu.dart';
part '../components/member.dart';
part '../components/task_in_progress.dart';
part '../components/weekly_task.dart';
part '../components/task_group.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool loading = false;
  String id = "";

  Future<void> getData() async {
    setState(() {
      loading = true;
    });
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newId = prefs.getString("id");

    setState(() {
      id = newId!;
    });

    setState(() {
      loading = false;
    });

  }

  void onPressedTask(int index, ListTaskAssignedData data) {}
  void onPressedAssignTask(int index, ListTaskAssignedData data) {}
  void onPressedMemberTask(int index, ListTaskAssignedData data) {}
  void onPressedCalendar() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCalenders()));
  }
  void onPressedTaskGroup(int index, ListTaskDateData data) {}

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ResponsiveBuilder(
            mobileBuilder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskContent(),
                    _buildCalendarContent(),
                  ],
                ),
              );
            },
            tabletBuilder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: constraints.maxWidth > 800 ? 8 : 7,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildTaskContent(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const VerticalDivider(),
                  ),
                  Flexible(
                    flex: 4,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildCalendarContent(),
                    ),
                  ),
                ],
              );
            },
            desktopBuilder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: constraints.maxWidth > 1350 ? 10 : 9,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildTaskContent(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const VerticalDivider(),
                  ),
                  Flexible(
                    flex: 4,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildCalendarContent(),
                    ),
                  ),
                ],
              );
            },
          ),
      )
    ;
  }


  Widget _buildTaskContent() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Column(
        children: [
          const SizedBox(height: kSpacing),
          Row(
            children: [
              Expanded(
                child: HeaderText(
                  DateTime.now().formatdMMMMY(),
                ),
              ),
              const SizedBox(width: kSpacing / 2),
            ],
          ),
          const SizedBox(height: kSpacing),
          FutureBuilder<String>(
            future: getCurrentOfficerId(),
            builder: (context, officerSnapshot) {
              if (officerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (officerSnapshot.hasError) {
                return Center(child: Text("Error: ${officerSnapshot.error}"));
              }
              String officerId = officerSnapshot.data!;

              // StreamBuilder for daily tasks
              return StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("farmers")
                    .where("officerId", isEqualTo: id)
                    .snapshots(),
                builder: (context, farmerSnapshot) {
                  if (farmerSnapshot.hasError) {
                    return Center(child: Text("Error: ${farmerSnapshot.error}"));
                  }
                  if (!farmerSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Extract classes from the retrieved farmers
                  List<String> farmerClasses = farmerSnapshot.data!.docs
                      .map((doc) => (doc.data() as Map<String, dynamic>)['class'] as String)
                      .toList();

                  // Daily tasks based on farmer classes
                  return StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("tasks")
                        .where("startDate", isGreaterThanOrEqualTo: startOfDay)
                        .where('endDate', isLessThan: endOfDay)
                        .where("class", whereIn: farmerClasses.isNotEmpty ? farmerClasses : ['dummy']) // Dummy if empty
                        .snapshots(),
                    builder: (context, taskSnapshot) {
                      if (taskSnapshot.hasError) {
                        return Center(child: Text("Error: ${taskSnapshot.error}"));
                      }

                      List<CardTaskData> taskInProgress = [];
                      if (taskSnapshot.hasData) {
                        taskInProgress = taskSnapshot.data!.docs.map((doc) {
                          return CardTaskData.fromFirestore(doc.data() as Map<String, dynamic>);
                        }).toList();
                      }

                      return CircularWidgetLoading(
                        loading: loading,
                        dotColor: Colors.green,
                        child: taskInProgress.isEmpty
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/search.png", height: 150),
                            const SizedBox(height: 20),
                            const Text(
                              'You have no tasks today ☺️',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Added tasks will appear here",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                          ],
                        )
                            : _TaskInProgress(data: taskInProgress),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: kSpacing * 2),
          _HeaderWeeklyTask(context: context),
          const SizedBox(height: kSpacing),
          FutureBuilder<String>(
            future: getCurrentOfficerId(),
            builder: (context, officerSnapshot) {
              if (officerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (officerSnapshot.hasError) {
                return Center(child: Text("Error: ${officerSnapshot.error}"));
              }
              String officerId = officerSnapshot.data!;

              // StreamBuilder for weekly tasks
              return StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("farmers")
                    .where("officerId", isEqualTo: id)
                    .snapshots(),
                builder: (context, farmerSnapshot) {
                  if (farmerSnapshot.hasError) {
                    return Center(child: Text("Error: ${farmerSnapshot.error}"));
                  }
                  if (!farmerSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Extract classes from the retrieved farmers
                  List<String> farmerClasses = farmerSnapshot.data!.docs
                      .map((doc) => (doc.data() as Map<String, dynamic>)['class'] as String)
                      .toList();

                  // Weekly tasks based on farmer classes
                  return StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("tasks")
                        .where("startDate", isGreaterThanOrEqualTo: startOfWeek)
                        .where("endDate", isLessThan: endOfWeek)
                        .where("class", whereIn: farmerClasses.isNotEmpty ? farmerClasses : ['dummy']) // Dummy if empty
                        .snapshots(),
                    builder: (context, taskSnapshot) {
                      if (taskSnapshot.hasError) {
                        return Center(child: Text("Error: ${taskSnapshot.error}"));
                      }

                      List<ListTaskAssignedData> weeklyTask = [];
                      if (taskSnapshot.hasData) {
                        weeklyTask = taskSnapshot.data!.docs.map((doc) {
                          return ListTaskAssignedData.fromFirestore(doc.data() as Map<String, dynamic>);
                        }).toList();
                      }

                      return CircularWidgetLoading(
                        loading: loading,
                        dotColor: Colors.green,
                        child: weeklyTask.isEmpty
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/search.png", height: 150),
                            const SizedBox(height: 20),
                            const Text(
                              'You have no tasks for this week',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Added tasks for this week will appear here",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                          ],
                        )
                            : _WeeklyTask(
                          data: weeklyTask,
                          onPressed: onPressedTask,
                          onPressedAssign: onPressedAssignTask,
                          onPressedMember: onPressedMemberTask,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

// Function to get the current officer ID from SharedPreferences
  Future<String> getCurrentOfficerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("officerId") ?? ""; // Return the officer ID or an empty string
  }



  Widget _buildCalendarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: CircularWidgetLoading(
        loading: loading,
        dotColor: Colors.green,
        child: Column(
          children: [
            const SizedBox(height: kSpacing),
            Row(
              children: [
                const Expanded(child: HeaderText("Calendar")),
                IconButton(
                  onPressed: onPressedCalendar,
                  icon: const Icon(Icons.date_range),
                  tooltip: "calendar",
                )
              ],
            ),
            FutureBuilder<String>(
              future: getCurrentOfficerId(),
              builder: (context, officerSnapshot) {
                if (officerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (officerSnapshot.hasError) {
                  return Center(child: Text("Error: ${officerSnapshot.error}"));
                }
                String officerId = officerSnapshot.data!;

                return StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("farmers")
                      .where("officerId", isEqualTo: id)
                      .snapshots(),
                  builder: (context, farmerSnapshot) {
                    if (farmerSnapshot.hasError) {
                      return Center(child: Text("Error: ${farmerSnapshot.error}"));
                    }
                    if (!farmerSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Extract classes from the retrieved farmers
                    List<String> farmerClasses = farmerSnapshot.data!.docs
                        .map((doc) => (doc.data() as Map<String, dynamic>)['class'] as String)
                        .toList();

                    // StreamBuilder for tasks based on farmer classes
                    return StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection("tasks").where("class", whereIn: farmerClasses.isNotEmpty ? farmerClasses : ['dummy']).snapshots(),
                      builder: (context, taskSnapshot) {
                        if (taskSnapshot.hasError) {
                          return Center(child: Text("Error: ${taskSnapshot.error}"));
                        }
                        if (taskSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        List<ListTaskDateData> tasks = taskSnapshot.data!.docs.map((doc) {
                          return ListTaskDateData.fromFirestore(doc.data() as Map<String, dynamic>);
                        }).toList();

                        List<List<ListTaskDateData>> groupedTasks = _groupedTasksBydate(tasks);

                        return Column(
                          children: [
                            const SizedBox(height: kSpacing),
                            ...groupedTasks
                                .map(
                                  (e) => _TaskGroup(
                                title: DateFormat('d MMMM').format(e[0].date),
                                data: e,
                                onPressed: onPressedTaskGroup,
                              ),
                            )
                                .toList(),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}

List<List<ListTaskDateData>> _groupedTasksBydate(List<ListTaskDateData> tasks){
  Map<String, List<ListTaskDateData>> groupedTaskMap = {};

  for (var task in tasks){
    String dateKey = DateFormat("yyyy-MM-dd").format(task.date);
    if (!groupedTaskMap.containsKey(dateKey)) {
      groupedTaskMap[dateKey] = [];
    }
    groupedTaskMap[dateKey]!.add(task);
  }

  List<String> sortedKeys = groupedTaskMap.keys.toList()..sort(
          (a, b) => DateTime.parse(a).compareTo(DateTime.parse(b))
  );

  List<List<ListTaskDateData>> groupedTasks = sortedKeys.map((key) =>
  groupedTaskMap[key]!).toList();
  return groupedTasks;
}
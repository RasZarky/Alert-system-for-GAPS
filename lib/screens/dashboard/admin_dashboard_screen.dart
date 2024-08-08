import 'dart:async';

import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/calender/new_task_dialog.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/header.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/user_details_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AdminDashboardScreen extends StatefulWidget {
  void Function() onTap;
  AdminDashboardScreen({
    super.key,required this.onTap
  });
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  Timer? _timer;
  List<Map<String, dynamic>> _tasksList = [];
  bool _isAnyTaskDue = false;

  @override
  void initState() {
    super.initState();
    _startTaskCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTaskCheck() async {
    // Retrieve the tasks from Firestore
    await _fetchTasksFromFirestore();

    // Check the tasks' end dates every minute
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print("checking again");
      _checkTaskEndDates();
    });
  }

  Future<void> _fetchTasksFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tasks') // Replace with your collection name
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _tasksList = querySnapshot.docs.map((doc) {
          Timestamp startDateTimestamp = doc['startDate'];
          return {
            'id': doc.id,
            'activity': doc['activity'],
            'class': doc['class'],
            'startDate': startDateTimestamp.toDate(),
            'endDate': doc['endDate'],
          };
        }).toList();
      });
    }
  }

  void _checkTaskEndDates() {
    DateTime now = DateTime.now();
    for (var task in _tasksList) {
      DateTime endDate = task['startDate'];
      if (now.isAfter(endDate) && now.isBefore(endDate.add( const Duration(minutes: 1)))) {
        _isAnyTaskDue = true;
        _onTaskDue(task);
      }
    }
    setState(() {});
  }

  void _onTaskDue(Map<String, dynamic> task) {
    // Your predefined function when a task's end date is up
    print("Task '${task['activity']}' for class '${task['class']}' is due! Running predefined function.");
    // Add your custom logic here
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        //padding: EdgeInsets.all(defaultPadding),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Header(onTap: widget.onTap),
              const SizedBox(height: defaultPadding),
                      ElevatedButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                            horizontal: defaultPadding * 1.5,
                            vertical: defaultPadding /
                                (Responsive.isMobile(context) ? 2 : 1),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const NewTaskDialog();
                                  },
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text(
                                "Add New Task",
                              ),
              ),
                      const SizedBox(height: defaultPadding,),
                      const UserDetailsWidget(),
              //       ),
              //   ],
              // )
            ],
          )
          ,
        ),
      ),
    );
  }
}

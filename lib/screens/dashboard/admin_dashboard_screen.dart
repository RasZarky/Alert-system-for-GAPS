import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/calender/new_task_dialog.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/header.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/user_details_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


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
    await _fetchTasksFromFirestore();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print("checking...");

      Fluttertoast.showToast(
          msg: "💚 Checking dates...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          fontSize: 16.0);

      _checkTaskEndDates();
    });
  }

  Future<void> _fetchTasksFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
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

  void _checkTaskEndDates() async {
    DateTime now = DateTime.now();
    for (var task in _tasksList) {
      DateTime endDate = task['startDate'];
      if (now.isAfter(endDate) && now.isBefore(endDate.add(const Duration(minutes: 1)))) {
        _isAnyTaskDue = true;
        await _onTaskDue(task);
      }
    }
    setState(() {});
  }

  Future<void> _onTaskDue(Map<String, dynamic> task) async {

    const String apiKey = '0bce26ec-8f46-4640-951a-aba560e44e64';
    final String senderId = 'ASFGAPS';

    print("Task '${task['activity']}' for class '${task['class']}' is due! Retrieving related farmers and officers.");

    Fluttertoast.showToast(
        msg: "Task '${task['activity']}' for class '${task['class']}' is due! Retrieving related farmers and officers.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 4,
        fontSize: 16.0);

    // Fetch farmers with the same class as the due activity
    QuerySnapshot farmerSnapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .where('class', isEqualTo: task['class'])
        .get();

    List<String> officerIds = [];
    List<Map<String, dynamic>> farmersList = [];

    for (var doc in farmerSnapshot.docs) {
      Map<String, dynamic> farmer = {
        'name': doc['name'],
        'number': doc['number'],
        'officerId': doc['officerId'],
      };
      farmersList.add(farmer);
      officerIds.add(doc['officerId']);
    }

    // Remove duplicate officer IDs
    officerIds = officerIds.toSet().toList();

    // Fetch users based on officer IDs
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: officerIds)
        .get();

    // Generate messages for farmers and users
    for (var farmer in farmersList) {
      print("Sending message to Farmer: ${farmer['name']}, Number: ${farmer['number']}");

      Fluttertoast.showToast(
          msg: "Sending message to Farmer: ${farmer['name']}, Number: ${farmer['number']}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          fontSize: 16.0);

      String farmerMessage = "Hello ${farmer['name']}, your activity '${task['activity']}' for class '${task['class']}' is now due and ends at '${task['endDate'].toDate().toString()}'.";

      final String url =
          'https://clientlogin.bulksmsgh.com/smsapi?key=$apiKey&to=${farmer['number']}&msg=$farmerMessage&sender_id=$senderId';

      try {
        final response = await http.get(Uri.parse(url));
        String result = response.body.trim();
        print(result);
      } catch (e) {
        print(e);
      }

      print(farmerMessage);
    }

    for (var userDoc in userSnapshot.docs) {
      String officerName = userDoc['name'];
      String officerPhone = userDoc['phoneNumber'];
      print("Sending message to Officer: $officerName, Number: $officerPhone");

      Fluttertoast.showToast(
          msg: "Sending message to Officer: $officerName, Number: $officerPhone",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          fontSize: 16.0);

      String officerMessage = "Hello $officerName, the activity '${task['activity']}' for your farmers in class '${task['class']}' is now due and ends at '${task['endDate'].toDate().toString()}'.";

      final String url =
          'https://clientlogin.bulksmsgh.com/smsapi?key=$apiKey&to=$officerPhone&msg=$officerMessage&sender_id=$senderId';

      try {
        final response = await http.get(Uri.parse(url));
        String result = response.body.trim();
        print(result);
      } catch (e) {
        print(e);
      }

      print(officerMessage);
    }
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

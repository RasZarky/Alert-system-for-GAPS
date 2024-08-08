import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/calender/new_task_dialog.dart';
import 'package:alert_system_for_gaps/screens/farmers/farmers_widget.dart';
import 'package:alert_system_for_gaps/screens/tasks/tasks_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksMainPage extends StatefulWidget {
  const TasksMainPage({super.key});

  @override
  State<TasksMainPage> createState() => _TasksMainPageState();
}

class _TasksMainPageState extends State<TasksMainPage> {
  String role = "";

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newRole = prefs.getString("role");
    print("/////////////////////////// $newRole");
    setState(() {
      role = newRole!;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                "All Tasks",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
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
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                height: defaultPadding,
              ),
              TasksWidget()
            ],
          )),
        ),
      ),
    );
  }
}

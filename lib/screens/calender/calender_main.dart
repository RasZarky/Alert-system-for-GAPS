import 'dart:math';
import 'package:alert_system_for_gaps/screens/calender/new_task_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendersMainPage extends StatefulWidget {
  @override
  CalendersMainPageState createState() => CalendersMainPageState();
}

class CalendersMainPageState extends State<CalendersMainPage> {
  List<Color> _colorCollection = <Color>[];
  final List<String> options = <String>['Add'];
  final databaseReference = FirebaseFirestore.instance;

  @override
  void initState() {
    _initializeEventColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(),
              PopupMenuButton<String>(
                icon: Icon(Icons.settings),
                itemBuilder: (BuildContext context) => options.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList(),
                onSelected: (String value) {
                  if (value == 'Add') {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const NewTaskDialog();
                      },
                    );
                  } else if (value == "Delete") {
                    try {
                      databaseReference
                          .collection('CalendarAppointmentCollection')
                          .doc('1')
                          .delete();
                    } catch (e) {}
                  } else if (value == "Update") {
                    try {
                      databaseReference
                          .collection('CalendarAppointmentCollection')
                          .doc('1')
                          .update({'Subject': 'Meeting'});
                    } catch (e) {}
                  }
                },
              )
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: databaseReference
              .collection("tasks")
              // .where("tutorId", isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, snapshot){
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
        )
    );
  }

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
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}

class Meeting {
  String? eventName;
  DateTime? from;
  DateTime? to;
  Color? background;
  bool? isAllDay;

  Meeting({this.eventName, this.from, this.to, this.background, this.isAllDay});
}
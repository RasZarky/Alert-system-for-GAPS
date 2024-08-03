import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/core/widgets/app_button_widget.dart';
import 'package:alert_system_for_gaps/core/widgets/input_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({super.key});

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  TextEditingController topicController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int _selectedClass = 0;
  List<String> classes = ["A","B","C","D","E",];
  bool loading = false;
  DateTime? initialDat ;
  DateTime? finalDate ;
  final databaseReference = FirebaseFirestore.instance;

  getData() async {
    setState(() {
      loading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: bgColor,
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: 750,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -34,
              top: 181.0,
              child: SvgPicture.string(
                // Group 3178
                '<svg viewBox="-34.0 181.0 99.0 99.0" ><path transform="translate(-34.0, 181.0)" d="M 74.25 0 L 99 49.5 L 74.25 99 L 24.74999618530273 99 L 0 49.49999618530273 L 24.7500057220459 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-26.57, 206.25)" d="M 0 0 L 42.07500076293945 16.82999992370605 L 84.15000152587891 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(15.5, 223.07)" d="M 0 56.42999649047852 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 99.0,
                height: 99.0,
              ),
            ),
            Positioned(
              right: -52,
              top: 45.0,
              child: SvgPicture.string(
                // Group 3177
                '<svg viewBox="288.0 45.0 139.0 139.0" ><path transform="translate(288.0, 45.0)" d="M 104.25 0 L 139 69.5 L 104.25 139 L 34.74999618530273 139 L 0 69.5 L 34.75000762939453 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(298.42, 80.45)" d="M 0 0 L 59.07500076293945 23.63000106811523 L 118.1500015258789 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(357.5, 104.07)" d="M 0 79.22999572753906 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 139.0,
                height: 139.0,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: CircularWidgetLoading(
                      loading: loading,
                      dotColor: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          richText(23.12),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Select Class",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: classes.toList().length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedClass = index;
                                      print(classes[_selectedClass]);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    width: 50,
                                    duration: Duration(milliseconds: 500),
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                        color: _selectedClass == index
                                            ? Colors.green[800]
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                        shape: BoxShape.rectangle),
                                    height: 40,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          classes.toList()[index],
                                          style: TextStyle(
                                              color: _selectedClass == index
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          InputWidget(
                            kController: topicController,
                            keyboardType: TextInputType.text,
                            onSaved: (String? value) {},
                            onChanged: (String? value) {},
                            validator: (String? value) {
                              return (value != null && value.contains('@'))
                                  ? 'Do not use the @ char.'
                                  : null;
                            },
                            topLabel: "Activity",
                            hintText: "Enter Activity details",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Start Date",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppButton(
                              type: ButtonType.PRIMARY,

                              text: "start Date",
                              onPressed: () async {
                                var date = await dateTimePickerWidget(context);
                                setState(() {
                                  initialDat = date;
                                });
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            initialDat == null
                                ? "Date not set"
                                : initialDat.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "End Date",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppButton(
                              type: ButtonType.PRIMARY,
                              text: "end Date",
                              onPressed: () async {
                                var date = await dateTimePickerWidget(context);
                                setState(() {
                                  finalDate = date;
                                });
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            finalDate == null
                                ? "Date not set"
                                : finalDate.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: AppButton(
                              type: ButtonType.PRIMARY,
                              text: 'Proceed',
                              onPressed: () async {
                                if (initialDat == null || finalDate == null) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title: Text("Invalid Dates"),
                                          content: Text(
                                              'Select start and end date for event'),
                                        );
                                      });
                                } else if (topicController.text.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title: Text(
                                              "All fields are required"),
                                          content: Text(
                                              'Please fill activity detail field'),
                                        );
                                      });
                                } else {
                                  setState(() {
                                    loading = true;
                                  });

                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  String? id = prefs.getString("id");

                                  await FirebaseFirestore.instance
                                      .collection('tasks')
                                      .add({
                                    'activity': topicController.text.trim(),
                                    'startDate': initialDat,
                                    'endDate': finalDate,
                                    'class': classes[_selectedClass],
                                    'id': id,
                                  });

                                  setState(() {
                                    loading = false;
                                  });

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const AlertDialog(
                                        title: Text(
                                          "Success",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        content: Text('Task Added'),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          color: Colors.white,
          letterSpacing: 1.999999953855673,
        ),
        children: const [
          TextSpan(
            text: 'Add new ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'TASK',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> dateTimePickerWidget(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(3000));

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());

    return selectedTime == null
        ? selectedDate
        : DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }
}

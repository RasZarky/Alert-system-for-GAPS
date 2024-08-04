import 'package:alert_system_for_gaps/screens/offficerHomePage/utils/helpers/app_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widget_loading/widget_loading.dart';

class CardTaskData {
  final String label;
  final DateTime createdOn;
  final String status;
  final String userName;
  final String jobDesk;
  final DateTime dueDate;

  const CardTaskData({
    required this.label,
    required this.status,
    required this.createdOn,
    required this.userName,
    required this.jobDesk,
    required this.dueDate,
  });

  factory CardTaskData.fromFirestore(Map<String, dynamic> data){
    return CardTaskData(
        label: data["activity"] ?? "",
        jobDesk: data["class"] ?? "",
        dueDate: (data["endDate"]).toDate() ?? "",
        userName: data["assignedTo"] ?? "",
        status: data["status"] ?? "",
        createdOn: (data["startDate"]).toDate() ?? "",
    );
  }
}

class CardTask extends StatefulWidget {
  const CardTask({
    required this.data,
    required this.primary,
    required this.onPrimary,
    Key? key,
  }) : super(key: key);

  final CardTaskData data;
  final Color primary;
  final Color onPrimary;

  @override
  State<CardTask> createState() => _CardTaskState();
}

class _CardTaskState extends State<CardTask> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        child: InkWell(
          onTap: () {},
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.primary, widget.primary.withOpacity(.7)],
                begin: AlignmentDirectional.topCenter,
                end: AlignmentDirectional.bottomCenter,
              ),
            ),
            child: _BackgroundDecoration(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildLabel(),
                          const SizedBox(height: 20),
                          _buildJobdesk(),
                          const SizedBox(height: 20),
                          _buildUserName(),
                        ],
                      ),
                    ),
                    const Spacer(flex: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDate(),
                        SizedBox(
                          height: 20,
                          child: VerticalDivider(
                            thickness: 1,
                            color: widget.onPrimary,
                          ),
                        ),
                        _buildHours(),
                      ],
                    ),
                    const Spacer(flex: 2),
                    _doneButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.data.label,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: widget.onPrimary,
        letterSpacing: 1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildJobdesk() {
    return Container(


      child: Row(
        children: [
          Text(
            "Class  ",
            style: TextStyle(
              color: widget.onPrimary,
              fontSize: 18,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextAvatar(
            size: 35,
            backgroundColor: Colors.white,
            textColor: Colors.white,
            fontSize: 14,
            upperCase: true,
            numberLetters: 1,
            shape: Shape.Rectangle,
            text: widget.data.jobDesk,
          ),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return Container(
      decoration: BoxDecoration(
        color: widget.onPrimary.withOpacity(.3),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        widget.data.userName,
        style: TextStyle(
          color: widget.onPrimary,
          fontSize: 10,
          letterSpacing: 1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDate() {
    return _IconLabel(
      color: widget.onPrimary,
      iconData: EvaIcons.calendarOutline,
      label: DateFormat('d MMM').format(widget.data.dueDate),
    );
  }

  Widget _buildHours() {
    return _IconLabel(
      color: widget.onPrimary,
      iconData: EvaIcons.clockOutline,
      label: widget.data.dueDate.dueDate(),
    );
  }

  Widget _doneButton() {
    return ElevatedButton.icon(
      onPressed: () async {

        setState(() {
          loading = true;
        });

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('CalendarAppointmentCollection')
            .where("createdOn", isEqualTo: widget.data.createdOn).get();

        if(querySnapshot.docs.isNotEmpty){

          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          String docId = documentSnapshot.id;

          FirebaseFirestore.instance
              .collection('CalendarAppointmentCollection')
              .doc(docId).update({
            "status": widget.data.status == "done" ? "undone" : "done"
          });

        }

        setState(() {
          loading = false;
        });

      },
      style: ElevatedButton.styleFrom(
        foregroundColor: widget.primary, backgroundColor: widget.onPrimary,
      ),
      icon: widget.data.status == "done" ?
            const Icon(EvaIcons.checkmarkCircle2)
            : const Icon(EvaIcons.checkmarkCircle2Outline),
      label: WiperLoading(
        loading: loading,
          wiperColor: widget.primary,
          child: const Text("Done")
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.color,
    required this.iconData,
    required this.label,
    Key? key,
  }) : super(key: key);

  final Color color;
  final IconData iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(.8),
          ),
        )
      ],
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Transform.translate(
            offset: const Offset(25, -25),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(.1),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Transform.translate(
            offset: const Offset(-70, 70),
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(.1),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

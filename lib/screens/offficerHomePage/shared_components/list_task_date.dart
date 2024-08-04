import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:widget_loading/widget_loading.dart';

import '../constans/app_constants.dart';

class ListTaskDateData {
  final DateTime date;
  final String label;
  final DateTime createdOn;
  final String jobdesk;

  const ListTaskDateData({
    required this.date,
    required this.label,
    required this.createdOn,
    required this.jobdesk,
  });

  factory ListTaskDateData.fromFirestore(Map<String, dynamic> data){
    return ListTaskDateData(
      label: data["activity"] ?? "",
      date: (data["startDate"]).toDate() ?? "",
      jobdesk: data["class"] ?? "",
      createdOn: (data["endDate"]).toDate() ?? "",
    );
  }
}

class ListTaskDate extends StatefulWidget {
  const ListTaskDate({
    required this.data,
    required this.onPressed,
    this.dividerColor,
    Key? key,
  }) : super(key: key);

  final ListTaskDateData data;
  final Function() onPressed;
  final Color? dividerColor;

  @override
  State<ListTaskDate> createState() => _ListTaskDateState();
}

class _ListTaskDateState extends State<ListTaskDate> {
  bool loadingD = false;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      secondaryActions: [
        // MaterialButton(
        //   color: Colors.yellow.withOpacity(0.15),
        //   elevation: 10,
        //   height: 40,
        //   minWidth: 40,
        //   shape: CircleBorder(),
        //   child: Icon(Icons.update, color: Colors.yellow, size: 30,),
        //   onPressed: () {
        //
        //   },
        // ),
        WiperLoading(
          loading: loadingD,
          wiperColor: Colors.green,
          child: MaterialButton(
            color: Colors.red.withOpacity(0.15),
            elevation: 20,
            height: 40,
            minWidth: 40,
            shape: CircleBorder(),
            child: Icon(Icons.delete, color: Colors.red, size: 30,),
            onPressed: () async {

              setState(() {
                loadingD = true;
              });
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('CalendarAppointmentCollection')
                  .where("createdOn", isEqualTo: widget.data.createdOn).get();

              if(querySnapshot.docs.isNotEmpty){

                DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
                String docId = documentSnapshot.id;

                FirebaseFirestore.instance.collection('CalendarAppointmentCollection').doc(docId).delete();

              }

              setState(() {
                loadingD = false;
              });

            },
          ),
        ),
      ],
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(kSpacing / 2),
          child: Row(
            children: [
              _buildHours(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacing),
                child: _buildDivider(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 5),
                    _buildSubtitle(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHours() {
    return Text(
      DateFormat.Hm().format(widget.data.date),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 3,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [
            widget.dividerColor ?? Colors.amber,
            widget.dividerColor?.withOpacity(.6) ?? Colors.amber.withOpacity(.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Class ${widget.data.jobdesk}",
      maxLines: 1,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w200,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.data.label,
      maxLines: 1,
      style: const TextStyle(fontWeight: FontWeight.w600),
      overflow: TextOverflow.ellipsis,
    );
  }
}

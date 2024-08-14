import 'dart:math';
import 'package:alert_system_for_gaps/screens/offficerHomePage/constans/app_constants.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/utils/helpers/app_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:widget_loading/widget_loading.dart';


class ListTaskAssignedData {
  final String label;
  final String jobDesk;
  final DateTime createdOn;
  final DateTime? editDate;
  final String? assignTo;

  const ListTaskAssignedData({
    required this.label,
    required this.jobDesk,
    required this.createdOn,
    this.editDate,
    this.assignTo,
  });

  factory ListTaskAssignedData.fromFirestore(Map<String, dynamic> data){
    return ListTaskAssignedData(
      label: data["activity"] ?? "",
      jobDesk: data["class"] ?? "",
      assignTo: data["class"] ?? "",
      createdOn: data["startDate"].toDate() ?? "",
    );
  }
}

class ListTaskAssigned extends StatefulWidget {
  ListTaskAssigned({
    required this.data,
    required this.onPressed,
    required this.onPressedAssign,
    required this.onPressedMember,
    Key? key,
  }) : super(key: key);

  final ListTaskAssignedData data;
  final Function() onPressed;
  final Function()? onPressedAssign;
  final Function()? onPressedMember;

  @override
  State<ListTaskAssigned> createState() => _ListTaskAssignedState();
}

class _ListTaskAssignedState extends State<ListTaskAssigned> {
  bool loadingD = false;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        motion: BehindMotion(),
        children: [
          WiperLoading(
            loading: loadingD,
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
                    .collection('tasks')
                    .where("startDate", isEqualTo: widget.data.createdOn).get();

                if(querySnapshot.docs.isNotEmpty){

                  DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
                  String docId = documentSnapshot.id;

                  FirebaseFirestore.instance.collection('tasks').doc(docId).delete();

                }

                setState(() {
                  loadingD = false;
                });

              },
            ),
          ),
        ],

      ),
      child: ListTile(
        onTap: widget.onPressed,
        hoverColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        leading: _buildIcon(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildAssign(),
      ),
    );
  }

  Icon _getSequenceIcon(int index) {
    int val = index % 4;
    if (val == 3) {
      return const Icon(EvaIcons.monitor, color: Colors.blueGrey);
    } else if (val == 2) {
      return const Icon(EvaIcons.star, color: Colors.amber);
    } else if (val == 1) {
      return const Icon(EvaIcons.colorPalette, color: Colors.blue);
    } else {
      return const Icon(EvaIcons.pieChart, color: Colors.redAccent);
    }
  }

  final Random random = Random();

  Widget _buildIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueGrey.withOpacity(.1),
      ),
      child: _getSequenceIcon(random.nextInt(3)),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.data.label,
      style: const TextStyle(fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    String edit = "";

    if (widget.data.editDate != null) {
      edit = " \u2022 edited ${timeago.format(widget.data.editDate!)}";
    }

    return Text(
      "Class ${widget.data.jobDesk}$edit",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAssign() {
    return (widget.data.assignTo != null)
        ? InkWell(
            onTap: widget.onPressedMember,
            borderRadius: BorderRadius.circular(22),
            child: Tooltip(
              message: widget.data.assignTo!,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.orange.withOpacity(.2),
                child: Text(
                  widget.data.assignTo!.getInitialName(2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        : DottedBorder(
            color: kFontColorPallets[1],
            strokeWidth: .3,
            strokeCap: StrokeCap.round,
            borderType: BorderType.Circle,
            child: IconButton(
              onPressed: widget.onPressedAssign,
              color: kFontColorPallets[1],
              iconSize: 15,
              icon: const Icon(EvaIcons.plus),
              splashRadius: 24,
              tooltip: "assign",
            ),
          );
  }
}

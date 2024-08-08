import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/core/utils/colorful_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';


class TasksWidget extends StatefulWidget {
  TasksWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  List<QueryDocumentSnapshot> _allItems = [];
  List<QueryDocumentSnapshot> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loading = false;


  Future<void> _loadItems() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("id");

    _firestore.collection('tasks').snapshots().listen((snapshot) {
      setState(() {
        _allItems = snapshot.docs;
        _filteredItems = _allItems;
      });
    });

    setState(() {
      loading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final data = item.data() as Map<String, dynamic>;
        final activity = data['activity'] as String;
        final classs = data['class'] as String;
        final startDate = (data['startDate'].toDate()).toString();
        final endDate = (data["endDate"].toDate()).toString();
        final searchText = _searchController.text.toLowerCase();
        return activity.toLowerCase().contains(searchText) ||
            endDate.toLowerCase().contains(searchText) ||
            startDate.toLowerCase().contains(searchText) ||
            classs.toLowerCase().contains(searchText) ;

      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Tasks(${_filteredItems.length})",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: Colors.white),
                ),
              ),
              Expanded(
                  child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Search Task activity, class, startDate, endDate...",
                  fillColor: bgColor,
                  filled: true,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(defaultPadding * 0.75),
                      margin: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/Search.svg",
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          CircularWidgetLoading(
            loading: loading,
            dotColor: Colors.green,
            child: SingleChildScrollView(
              //scrollDirection: Axis.horizontal,
              child: _filteredItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                              opacity: .7,
                              child: Image(
                                image: AssetImage("assets/images/search.png"),
                                height: 150,
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "No Tasks",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              child: DataTable(
                                horizontalMargin: 0,
                                columnSpacing: defaultPadding,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "Activity",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        "Start Date",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("Class",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("End Date",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("Operation",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                                rows: List.generate(
                                  _filteredItems.length,
                                  (index) => recentUserDataRow(
                                    _filteredItems[index].data() as Map<String, dynamic>,
                                    context,
                                        () {

                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentUserDataRow(Map<String, dynamic> userInfo, BuildContext context,
    void Function() more) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            TextAvatar(
              size: 35,
              backgroundColor: Colors.white,
              textColor: Colors.white,
              fontSize: 14,
              upperCase: true,
              numberLetters: 1,
              shape: Shape.Rectangle,
              text: userInfo["name"].contains(RegExp(r'\d')) ? "Q" : "${userInfo["name"]}",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "${userInfo["activity"]}",
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      DataCell(Text(
        (userInfo["startDate"].toDate()).toString(),
        style: const TextStyle(color: Colors.white),
      )),
      DataCell(Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: getRoleColor(userInfo["class"].toString()).withOpacity(.2),
            border: Border.all(color: getRoleColor(userInfo["class"].toString())),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(
            userInfo["class"].toString(),
            style: const TextStyle(color: Colors.white),
          ))),
      DataCell(Text(
        (userInfo["endDate"].toDate()).toString(),
        style: const TextStyle(color: Colors.white),
      )),
      DataCell(
        TextButton(
          child: const Text("More",
              style: TextStyle(color: Colors.orangeAccent)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  List<dynamic> completedUsers = userInfo["completedUsers"];

                  return AlertDialog(
                      backgroundColor: Colors.black,
                      title: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.list_alt,
                                size: 36, color: Colors.green),
                            const SizedBox(height: 20),
                            Text(
                              "Officers who completed: '${userInfo["activity"]}' for class ${userInfo["class"]}",
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      content: SizedBox(
                        height: 300,
                        width: double.maxFinite,
                        child: ListView.builder(
                          itemCount: completedUsers.length,
                          itemBuilder: (context, index) {
                            var user = completedUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user["userName"][0]),
                              ),
                              title: Text(
                                user["userName"],
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "ID: ${user["userId"]}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            );
                          },
                        ),
                      ));
                });
          },
        ),
      ),
    ],
  );
}

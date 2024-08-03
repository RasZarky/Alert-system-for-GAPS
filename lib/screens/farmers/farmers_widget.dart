import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/core/utils/colorful_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';


class FarmersWidget extends StatefulWidget {
  FarmersWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FarmersWidget> createState() => _FarmersWidgetState();
}

class _FarmersWidgetState extends State<FarmersWidget> {
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

    _firestore.collection('farmers').where("officerId", isEqualTo: id).snapshots().listen((snapshot) {
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
        final name = data['name'] as String;
        final location = data['location'] as String;
        final classs = data['class'] as String;
        final size = data["size"] as String;
        final number = data["number"] as String;
        final searchText = _searchController.text.toLowerCase();
        return name.toLowerCase().contains(searchText) ||
            location.toLowerCase().contains(searchText) ||
            classs.toLowerCase().contains(searchText) ||
            number.toLowerCase().contains(searchText) ||
            size.toLowerCase().contains(searchText);
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
                  "Farmers(${_filteredItems.length})",
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
                  hintText: "Search farmer name, farm class, size, location,number...",
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
                            "No Farmers",
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
                                      "Farmer name",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        "Farm location",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("Class",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("Size",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("Number", style: TextStyle(
                                        color: Colors.white
                                    )),
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
                                      FirebaseFirestore.instance
                                          .collection('farmers')
                                          .doc(_filteredItems[index].id)
                                          .delete();

                                      Navigator.pop(context);
                                    },
                                    () {
                                      FirebaseFirestore.instance
                                          .collection('farmers')
                                          .doc(_filteredItems[index].id)
                                          .update({
                                        'class': "A",
                                      });
                                    },
                                        () {
                                      FirebaseFirestore.instance
                                          .collection('farmers')
                                          .doc(_filteredItems[index].id)
                                          .update({
                                        'class': "B",
                                      });
                                    },() {
                                    FirebaseFirestore.instance
                                        .collection('farmers')
                                        .doc(_filteredItems[index].id)
                                        .update({
                                      'class': "C",
                                    });
                                  },() {
                                    FirebaseFirestore.instance
                                        .collection('farmers')
                                        .doc(_filteredItems[index].id)
                                        .update({
                                      'class': "D",
                                    });
                                  },() {
                                    FirebaseFirestore.instance
                                        .collection('farmers')
                                        .doc(_filteredItems[index].id)
                                        .update({
                                      'class': "E",
                                    });
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
    void Function() delete, a, b, c, d, e,) {
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
              text: "${userInfo["name"]}",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                "${userInfo["name"]}",
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      DataCell(Text(
        userInfo["location"],
        style: const TextStyle(color: Colors.white),
      )),
      DataCell(Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: getRoleColor(userInfo["class"].toString()).withOpacity(.2),
            border: Border.all(color: getRoleColor(userInfo["class"].toString())),
            borderRadius: const BorderRadius.all(Radius.circular(5.0) //
            ),
          ),
          child: Text(
            userInfo["class"].toString(),
            style: const TextStyle(color: Colors.white),
          ))),
      DataCell(Text(
        userInfo["size"],
        style: const TextStyle(color: Colors.white),
      )),
      DataCell(Text(
        (userInfo["number"]).toString(),
        style: const TextStyle(color: Colors.white),
      )),
      // DataCell(Text(userInfo.posts!, style: const TextStyle(
      //     color: Colors.white
      // ),)),
      DataCell(
        TextButton(
          child: const Text("Update",
              style: TextStyle(color: Colors.redAccent)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                      backgroundColor: secondaryColor,
                      title: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.warning_outlined,
                                size: 36, color: Colors.red),
                            const SizedBox(height: 20),
                            Text(
                              "Update farm class for farmer: '${userInfo["name"]}'",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      content: SizedBox(
                        height: 300,
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 14,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: delete,
                                label: const Text("Delete")),
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: a,
                              child: const Text(
                                "Class A",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: b,
                              child: const Text(
                                "Class B",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent),
                              onPressed: c,
                              child: const Text(
                                "Class C",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent),
                              onPressed: d,
                              child: const Text(
                                "Class D",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent),
                              onPressed: e,
                              child: const Text(
                                "Class E",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ));
                });
          },
          // Delete
        ),
      ),
    ],
  );
}

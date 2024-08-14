import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:widget_loading/widget_loading.dart';


class AdminsWidget extends StatefulWidget {
  AdminsWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminsWidget> createState() => _AdminsWidgetState();
}

class _AdminsWidgetState extends State<AdminsWidget> {
  List<QueryDocumentSnapshot> _allItems = [];
  List<QueryDocumentSnapshot> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loading = false;


  Future<void> _loadItems() async {
    setState(() {
      loading = true;
    });

    _firestore.collection('users').where("role", isEqualTo: "admin").snapshots().listen((snapshot) {
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
        final id = data['id'] as String;
        final number = data['phoneNumber'] as String;
        final searchText = _searchController.text.toLowerCase();
        return name.toLowerCase().contains(searchText) ||
            id.toLowerCase().contains(searchText) ||
            number.toLowerCase().contains(searchText);
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
                  "Admins(${_filteredItems.length})",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
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
                  hintText: "Search Officer admin, id,number...",
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
                            "No admins",
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
                                      "Name",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        "Id",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  DataColumn(
                                    label: Text("Number",
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

DataRow recentUserDataRow(Map<String, dynamic> userInfo, BuildContext context) {
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
        userInfo["id"],
        style: const TextStyle(color: Colors.white),
      )),
      DataCell(Text(
        userInfo["phoneNumber"],
        style: const TextStyle(color: Colors.white),
      )),
      DataCell(
        TextButton(
          child: const Text("Update",
              style: TextStyle(color: Colors.redAccent)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  return const AlertDialog(
                      backgroundColor: secondaryColor,
                      title: Center(
                        child: Column(
                          children: [
                            Icon(Icons.warning_outlined,
                                size: 36, color: Colors.red),
                            SizedBox(height: 20),
                            Text(
                              "Action not allowed",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  );
                });
          },
          // Delete
        ),
      ),
    ],
  );
}

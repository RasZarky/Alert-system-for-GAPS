import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/core/utils/colorful_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_loading/widget_loading.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

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
            classs.toLowerCase().contains(searchText);
      }).toList();
    });
  }

  void _generateReport(DateTime startDate, DateTime endDate) {
    final reportItems = _allItems.where((item) {
      final data = item.data() as Map<String, dynamic>;
      final taskStartDate = data['startDate'].toDate() as DateTime;
      return taskStartDate.isAfter(startDate) && taskStartDate.isBefore(endDate);
    }).toList();

    final formattedStartDate = DateFormat.yMMMMd().format(startDate);
    final formattedEndDate = DateFormat.yMMMMd().format(endDate);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Report',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report from $formattedStartDate to $formattedEndDate',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...reportItems.map((item) {
                final data = item.data() as Map<String, dynamic>;
                final completedUsers = data['completedUsers'] as List<dynamic>;
                final taskStartDate = DateFormat.yMMMMd().format(data['startDate'].toDate());

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity: ${data["activity"]}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Class: ${data["class"]}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Start Date: $taskStartDate',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Completed by:',
                      style: const TextStyle(color: Colors.white),
                    ),
                    ...completedUsers.map((user) {
                      return Text(
                        '- ${user["userName"]} (ID: ${user["userId"]})',
                        style: const TextStyle(color: Colors.white70),
                      );
                    }).toList(),
                    const Divider(color: Colors.white),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              _printReport(reportItems, formattedStartDate, formattedEndDate);
            },
            child: const Text(
              'Print',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReport(List<QueryDocumentSnapshot> reportItems, String startDate, String endDate) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Alert System For GAPS', style: pw.TextStyle(fontSize: 23, fontWeight: pw.FontWeight.bold)),
          pw.Text('Report from $startDate to $endDate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          ...reportItems.map((item) {
            final data = item.data() as Map<String, dynamic>;
            final completedUsers = data['completedUsers'] as List<dynamic>;
            final taskStartDate = DateFormat.yMMMMd().format(data['startDate'].toDate());

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Activity: ${data["activity"]}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Class: ${data["class"]}'),
                pw.Text('Start Date: $taskStartDate'),
                pw.Text('Completed by:'),
                ...completedUsers.map((user) {
                  return pw.Text('- ${user["userName"]} (ID: ${user["userId"]})');
                }).toList(),
                pw.Divider(),
                pw.SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null && picked != DateTimeRange(start: DateTime.now(), end: DateTime.now())) {
      _generateReport(picked.start, picked.end);
    }
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
                ),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: _selectDateRange,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          CircularWidgetLoading(
            loading: loading,
            dotColor: Colors.green,
            child: SingleChildScrollView(
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
                              label: Text("Start Date",
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
                                FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(_filteredItems[index].id)
                                    .delete();

                                Navigator.pop(context);
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
    void Function() delete) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
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
        Row(
          children: [
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
            TextButton(
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
                                    "Are you sure you want to delete task: '${userInfo["activity"]}' \n"
                                        "For class '${userInfo["class"]}'",
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
                                ],
                              ),
                            ));
                      });
                },
                child: const Text("Delete",
                    style: TextStyle(color: Colors.red))
            ),
          ],
        ),
      ),
    ],
  );
}

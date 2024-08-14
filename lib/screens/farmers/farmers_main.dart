import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/farmers/admin_farmers_widget.dart';
import 'package:alert_system_for_gaps/screens/farmers/farmers_widget.dart';
import 'package:alert_system_for_gaps/screens/farmers/new_farmer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmersMainPage extends StatefulWidget {
  const FarmersMainPage({super.key});

  @override
  State<FarmersMainPage> createState() => _FarmersMainPageState();
}

class _FarmersMainPageState extends State<FarmersMainPage> {
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
                "All Farmers",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const Spacer(),
              role == "extension officer"
                  ? ElevatedButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical: defaultPadding /
                        (Responsive.isMobile(context) ? 2 : 1),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const NewFarmerDialog();
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add Farmer",
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
              child: role == "extension officer"
                  ? FarmersWidget()
                  : role == "admin"
                      ? AdminFarmersWidget()
                      : Container()),
        ),
      ),
    );
  }
}

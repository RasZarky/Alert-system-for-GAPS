import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/screens/admins/admins_widget.dart';
import 'package:alert_system_for_gaps/screens/extensionOfficer/officers_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdminsMainPage extends StatefulWidget {
  const AdminsMainPage({super.key});

  @override
  State<AdminsMainPage> createState() => _AdminsMainPageState();
}

class _AdminsMainPageState extends State<AdminsMainPage> {
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
                "All Admins",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: defaultPadding,
                  ),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 550),
                      child: AdminsWidget())
            ],
          )),
        ),
      ),
    );
  }
}

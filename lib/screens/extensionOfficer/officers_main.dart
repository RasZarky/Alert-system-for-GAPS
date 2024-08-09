import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/extensionOfficer/new_officer_dialog.dart';
import 'package:alert_system_for_gaps/screens/extensionOfficer/officers_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OfficersMainPage extends StatefulWidget {
  const OfficersMainPage({super.key});

  @override
  State<OfficersMainPage> createState() => _OfficersMainPageState();
}

class _OfficersMainPageState extends State<OfficersMainPage> {

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
                "All Officers",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton.icon(
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
                      return const NewOfficerDialog();
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add Officer",
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 550
                  ),
                  child: OfficersWidget())),
        ),
      ),
    );
  }
}

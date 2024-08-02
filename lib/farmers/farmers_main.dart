import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/farmers/farmers_widget.dart';
import 'package:alert_system_for_gaps/farmers/new_farmer_dialog.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:flutter/material.dart';

class FarmersMainPage extends StatefulWidget {
  const FarmersMainPage({super.key});

  @override
  State<FarmersMainPage> createState() => _FarmersMainPageState();
}

class _FarmersMainPageState extends State<FarmersMainPage> {
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
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Colors.white
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
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
                  "Add New Farmer",
                ),
              ),
              SizedBox(height: defaultPadding,),
              FarmersWidget(),
            ],
          )),
        ),
      ),
    );
  }
}

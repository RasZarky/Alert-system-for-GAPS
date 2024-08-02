import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/farmers/farmers_main.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/home/components/side_menu.dart';
import 'package:flutter/material.dart';

class AllFarmers extends StatelessWidget {
  const AllFarmers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      //key: context.read<MenuController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            const Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: FarmersMainPage(),
            ),
          ],
        ),
      ),
    );
  }
}
